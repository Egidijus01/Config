local ConfigService = require("api/ConfigService")

local Config = ConfigService:new({

	anonymous = true,
})

local ConfigFile = Config:section(
	"interfaces", -- UCI config name
	"interface"  -- UCI section type
)
ConfigFile:make_primary()



local name = ConfigFile:option("name")
	name.cfg_require = true
	name.maxlength = 100
	name.minlength = 5

	function name:validate(value)
		local pass = true
		self:table_foreach(self.config, "interface", function (d)
			local names = self:table_get(self.config, d[".name"])
			for _,n in pairs(names) do
				if n == value then
					pass = false
					break
				end
			end
		end)
		return pass
	end

	function name:set(value)
		local val = self:table_get(self.config, self.sid, "name")
		if val then
			return self:table_set(self.config, self.sid, "name", val)
		else
			return self:table_set(self.config, self.sid, "name", value)

		end
	end


local address = ConfigFile:option("address")
	address.cfg_require = true

    address.maxlength = 100
    address.minlength = 5

    function address:validate(value)
        return self.dt:ip4addr(value)
    end

local netmask = ConfigFile:option("netmask")
	netmask.cfg_require = true

    netmask.maxlength = 100
    netmask.minlength = 5

    function netmask:validate(value)
        return self.dt:netmask(value)
    end


local opt_dns_addresses = ConfigFile:option("dns", { list = true })
    opt_dns_addresses.maxlength = 200

    function opt_dns_addresses:validate(value)
        return self.dt:ip4addr(value)
    end


local protocol = ConfigFile:option("protocol")
	function protocol:validate(value)
		return self.dt:check_array(value, { "static", "dhcp" })
	end
	
	function protocol:set(value)
		if value == "dhcp" then

				self:table_delete(self.config, self.sid, "address")
				self:table_delete(self.config, self.sid, "netmask")
				self:table_delete(self.config, self.sid, "protocol")
			
		end

	
end


return Config
