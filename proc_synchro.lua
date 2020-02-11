if not aux.SynchroProcedure then
	aux.SynchroProcedure = {}
	Synchro = aux.SynchroProcedure
end
if not Synchro then
	Synchro = aux.SynchroProcedure
end
function Synchro.NonTuner(f,a,b,c)
	return	function(target,scard,sumtype,tp)
				return target:IsNotTuner(scard,tp) and (not f or f(target,a,b,c))
			end
end
function Synchro.NonTunerEx(f,val)
	return	function(target,scard,sumtype,tp)
				return target:IsNotTuner(scard,tp) and f(target,val,scard,sumtype,tp)
			end
end
function Synchro.NonTunerCode(...)
	local params={...}
	return	function(target,scard,sumtype,tp)
				return target:IsNotTuner(scard,tp) and target:IsSummonCode(scard,sumtype,tp,table.unpack(params))
			end
end
--Synchro monster, m-n tuners + m-n monsters
function Synchro.AddProcedure(c,...)
	--parameters (f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm)
	if c.synchro_type==nil then
		local code=c:GetOriginalCode()
		local mt=c:GetMetatable()
		mt.synchro_type=1
		mt.synchro_parameters={...}
		if type(mt.synchro_parameters[2])=='function' then
			Debug.Message("Old Synchro Procedure detected in c"..code..".lua")
			return
		end
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1172)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Synchro.Condition(...))
	e1:SetTarget(Synchro.Target(...))
	e1:SetOperation(Synchro.Operation)
	e1:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e1)
end
function Synchro.CheckFilterChk(c,f1,f2,sub1,sub2,sc,tp)
	local te=c:GetCardEffect(EFFECT_SYNCHRO_CHECK)
	if not te then return false end
	local f=te:GetValue()
	local reset=false
	if f(te,c) then
		reset=true
	end
	local res=(c:IsType(TYPE_TUNER,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp) and (not f1 or f1(c,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp))) or not f2 or f2(c,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp) or (sub1 and sub1(c,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp)) or (sub2 and sub2(c,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp))
	if reset then
		Duel.AssumeReset()
	end
	return res
end
function Synchro.TunerFilter(c,f1,sub1,sc,tp)
	return (c:IsType(TYPE_TUNER,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp) and (not f1 or f1(c,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp))) or (sub1 and sub1(c,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp))
end
function Synchro.NonTunerFilter(c,f2,sub2,sc,tp)
	return not f2 or f2(c,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp) or (sub2 and sub2(c,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp))
end
function Synchro.Condition(f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm)
	return	function(e,c,smat,mg,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local dg
				local lv=c:GetLevel()
				local g
				local mgchk
				if mg then
					dg=mg
					g=mg:Filter(Card.IsCanBeSynchroMaterial,c,c)
					mgchk=true
				else
					dg=Duel.GetMatchingGroup(function(mc) return mc:IsFaceup() and (mc:IsControler(tp) or mc:IsCanBeSynchroMaterial(c)) end,tp,LOCATION_MZONE,LOCATION_MZONE,c)
					g=dg:Filter(Card.IsCanBeSynchroMaterial,nil,c)
					mgchk=false
				end
				local pg=Auxiliary.GetMustBeMaterialGroup(tp,dg,tp,c,g,REASON_SYNCHRO)
				if not g:Includes(pg) or pg:IsExists(aux.NOT(Card.IsCanBeSynchroMaterial),1,nil,c) then return false end
				if smat then
					if smat.KeepAlive then
						if smat:IsExists(aux.NOT(Card.IsCanBeSynchroMaterial),1,nil,c) then return false end
						pg:Merge(smat)
						g:Merge(smat)
					else
						if not smat:IsCanBeSynchroMaterial(c) then return false end
						pg:AddCard(smat)
						g:AddCard(smat)
					end
				end
				if g:IsExists(Synchro.CheckFilterChk,1,nil,f1,f2,sub1,sub2,c,tp) then
					--if there is a monster with EFFECT_SYNCHRO_CHECK (Genomix Fighter/Mono Synchron)
					local g2=g:Clone()
					if not mgchk then
						local thg=g2:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO)
						local hg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND+LOCATION_GRAVE,0,c,c)
						for thc in aux.Next(thg) do
							local te=thc:GetCardEffect(EFFECT_HAND_SYNCHRO)
							local val=te:GetValue()
							local ag=hg:Filter(function(mc) return val(te,mc,c) end,nil) --tuner
							g2:Merge(ag)
						end
					end
					local res=g2:IsExists(Synchro.CheckP31,1,nil,g2,Group.CreateGroup(),Group.CreateGroup(),Group.CreateGroup(),f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
					local hg=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
					aux.ResetEffects(hg,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
					Duel.AssumeReset()
					return res
				else
					--no race change
					local tg
					local ntg
					if mgchk then
						tg=g:Filter(Synchro.TunerFilter,nil,f1,sub1,c,tp)
						ntg=g:Filter(Synchro.NonTunerFilter,nil,f2,sub2,c,tp)
					else
						tg=g:Filter(Synchro.TunerFilter,nil,f1,sub1,c,tp)
						ntg=g:Filter(Synchro.NonTunerFilter,nil,f2,sub2,c,tp)
						local thg=tg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO)
						thg:Merge(ntg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO))
						local hg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND+LOCATION_GRAVE,0,c,c)
						for thc in aux.Next(thg) do
							local te=thc:GetCardEffect(EFFECT_HAND_SYNCHRO)
							local val=te:GetValue()
							local thag=hg:Filter(function(mc) return Synchro.TunerFilter(mc,f1,sub1,c,tp) and val(te,mc,c) end,nil) --tuner
							local nthag=hg:Filter(function(mc) return Synchro.NonTunerFilter(mc,f2,sub2,c,tp) and val(te,mc,c) end,nil) --non-tuner
							tg:Merge(thag)
							ntg:Merge(nthag)
						end
					end
					local lv=c:GetLevel()
					local res=tg:IsExists(Synchro.CheckP41,1,nil,tg,ntg,Group.CreateGroup(),Group.CreateGroup(),Group.CreateGroup(),min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
					local hg=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
					aux.ResetEffects(hg,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
					return res
				end
				return false
			end
end
function Synchro.CheckP31(c,g,tsg,ntsg,sg,f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	local res
	local rg=Group.CreateGroup()
	if c:IsHasEffect(EFFECT_SYNCHRO_CHECK) then
		local teg={c:GetCardEffect(EFFECT_SYNCHRO_CHECK)}
		for i=1,#teg do
			local te=teg[i]
			local val=te:GetValue()
			local tg=g:Filter(function(mc) return val(te,mc) end,nil)
			rg=tg:Filter(function(mc) return not Synchro.TunerFilter(mc,f1,sub1,sc,tp) and not Synchro.NonTunerFilter(mc,f2,sub2,sc,tp) end,nil)
		end
	end
	--c has the synchro limit
	if c:IsHasEffect(EFFECT_SYNCHRO_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then return false end
			local sg1=g:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			rg:Merge(sg1)
		end
	end
	--A card in the selected group has the synchro lmit
	local g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MAT_RESTRICTION)
	for tc in aux.Next(g2) do
		local eff={tc:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then return false end
		end
	end
	if not mgchk then
		if c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then
			local teg={c:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for i=1,#teg do
				local te=teg[i]
				local tgchk=te:GetTarget()
				local res,trg,ntrg2=tgchk(te,c,sg,g,g,tsg,ntsg)
				--if not res then return false end
				if res then
					rg:Merge(trg)
					hanchk=true
					break
				end
			end
			if not hanchk then return false end
		end
		g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
		for tc in aux.Next(g2) do
			local eff={tc:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for _,te in ipairs(eff) do
				if te:GetTarget()(te,nil,sg,g,g,tsg,ntsg) then
					hanchk=true
					break
				end
			end
			if not hanchk then return false end
		end
	end
	g:Sub(rg)
	tsg:AddCard(c)
	sg:AddCard(c)
	local tsg_count=#tsg
	if max and (tsg_count>max or (max-tsg_count)<min2) then
		res = false
	elseif max and (max-tsg_count)==min2 then
		res=tsg:IsExists(Synchro.TunerFilter,tsg_count,nil,f1,sub1,sc,tp) and (not req1 or req1(tsg,sc,tp)) 
			and g:IsExists(Synchro.CheckP32,1,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	elseif tsg_count<min1 then
		res=g:IsExists(Synchro.CheckP31,1,sg,g,tsg,ntsg,sg,f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	elseif tsg_count<max1 then
		res=g:IsExists(Synchro.CheckP31,1,sg,g,tsg,ntsg,sg,f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,sc,tp,pg,mgchk,min,max) 
			or (tsg:IsExists(Synchro.TunerFilter,tsg_count,nil,f1,sub1,sc,tp) and (not req1 or req1(tsg,sc,tp)) 
				and g:IsExists(Synchro.CheckP32,1,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max))
	else
		res=tsg:IsExists(Synchro.TunerFilter,tsg_count,nil,f1,sub1,sc,tp) and (not req1 or req1(tsg,sc,tp)) 
			and g:IsExists(Synchro.CheckP32,1,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	end
	g:Merge(rg)
	tsg:RemoveCard(c)
	sg:RemoveCard(c)
	if not sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_CHECK) then
		Duel.AssumeReset()
	end
	return res
end
function Synchro.CheckP32(c,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	local res
	local rg=Group.CreateGroup()
	if c:IsHasEffect(EFFECT_SYNCHRO_CHECK) then
		local teg={c:GetCardEffect(EFFECT_SYNCHRO_CHECK)}
		for i=1,#teg do
			local te=teg[i]
			local val=te:GetValue()
			local tg=g:Filter(function(mc) return val(te,mc) end,nil)
			rg=tg:Filter(function(mc) return not Synchro.NonTunerFilter(mc,f2,sub2,sc,tp) end,nil)
		end
	end
	--c has the synchro limit
	if c:IsHasEffect(EFFECT_SYNCHRO_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then return false end
			local sg2=g:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			rg:Merge(sg2)
		end
	end
	--A card in the selected group has the synchro lmit
	local g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MAT_RESTRICTION)
	for tc in aux.Next(g2) do
		local eff={tc:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then return false end
		end
	end
	if not mgchk then
		if c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then
			local teg={c:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for i=1,#teg do
				local te=teg[i]
				local tgchk=te:GetTarget()
				local res,trg2,ntrg2=tgchk(te,c,sg,Group.CreateGroup(),g,tsg,ntsg)
				--if not res then return false end
				if res then
					rg:Merge(ntrg2)
					hanchk=true
					break
				end
			end
			if not hanchk then return false end
		end
		g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
		for tc in aux.Next(g2) do
			local eff={tc:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for _,te in ipairs(eff) do
				if te:GetTarget()(te,nil,sg,Group.CreateGroup(),g,tsg,ntsg) then
					hanchk=true
					break
				end
			end
			if not hanchk then return false end
		end
	end
	g:Sub(rg)
	ntsg:AddCard(c)
	sg:AddCard(c)
	local tsg_count=#tsg
	local ntsg_count=#ntsg
	if max and (tsg_count+ntsg_count)>max then
		res = false
	elseif ntsg_count<min2 then
		res=g:IsExists(Synchro.CheckP32,1,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	elseif ntsg_count<max2 then
		res=g:IsExists(Synchro.CheckP32,1,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max) 
			or ((not min or (tsg_count+ntsg_count)>=min) and (not req2 or req2(ntsg,sc,tp)) and (not reqm or reqm(sg,sc,tp)) 
				and ntsg:IsExists(Synchro.NonTunerFilter,ntsg_count,nil,f2,sub2,sc,tp) 
				and sg:Includes(pg) and Synchro.CheckP43(tsg,ntsg,sg,lv,sc,tp))
	else
		res=(not min or (tsg_count+ntsg_count)>=min) and (not req2 or req2(ntsg,sc,tp)) and (not reqm or reqm(sg,sc,tp)) 
			and ntsg:IsExists(Synchro.NonTunerFilter,ntsg_count,nil,f2,sub2,sc,tp)
			and sg:Includes(pg) and Synchro.CheckP43(tsg,ntsg,sg,lv,sc,tp)
	end
	g:Merge(rg)
	ntsg:RemoveCard(c)
	sg:RemoveCard(c)
	if not sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_CHECK) then
		Duel.AssumeReset()
	end
	return res
end
function Synchro.CheckP41(c,tg,ntg,tsg,ntsg,sg,min1,max1,min2,max2,req1,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	local res
	local trg=Group.CreateGroup()
	local ntrg=Group.CreateGroup()
	--c has the synchro limit
	if c:IsHasEffect(EFFECT_SYNCHRO_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then return false end
			local sg1=tg:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			local sg2=ntg:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			trg:Merge(sg1)
			ntrg:Merge(sg2)
		end
	end
	--A card in the selected group has the synchro lmit
	local g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MAT_RESTRICTION)
	for tc in aux.Next(g2) do
		local eff={tc:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then return false end
		end
	end
	if not mgchk then
		if c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then
			local teg={c:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for _,te in ipairs(teg) do
				local tgchk=te:GetTarget()
				local res,trg2,ntrg2=tgchk(te,c,sg,tg,ntg,tsg,ntsg)
				--if not res then return false end
				if res then
					trg:Merge(trg2)
					ntrg:Merge(ntrg2)
					hanchk=true
					break
				end
			end
			if not hanchk then return false end
		end
		g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
		for tc in aux.Next(g2) do
		local eff={tc:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for _,te in ipairs(eff) do
				if te:GetTarget()(te,nil,sg,tg,ntg,tsg,ntsg) then
					hanchk=true
					break
				end
			end
			if not hanchk then return false end
		end
	end
	tg:Sub(trg)
	ntg:Sub(ntrg)
	tsg:AddCard(c)
	sg:AddCard(c)
	local tsg_count=#tsg
	if max and (tsg_count>max or (max-tsg_count)<min2) then
		res = false
	elseif max and (max-tsg_count)==min2 then
		res=(not req1 or req1(tsg,sc,tp)) 
			and ntg:IsExists(Synchro.CheckP42,1,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	elseif tsg_count<min1 then
		res=tg:IsExists(Synchro.CheckP41,1,sg,tg,ntg,tsg,ntsg,sg,min1,max1,min2,max2,req1,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	elseif tsg_count<max1 then
		res=tg:IsExists(Synchro.CheckP41,1,sg,tg,ntg,tsg,ntsg,sg,min1,max1,min2,max2,req1,req2,reqm,lv,sc,tp,pg,mgchk,min,max) 
			or ((not req1 or req1(tsg,sc,tp)) and ntg:IsExists(Synchro.CheckP42,1,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max))
	else
		res=(not req1 or req1(tsg,sc,tp)) 
			and ntg:IsExists(Synchro.CheckP42,1,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	end
	tg:Merge(trg)
	ntg:Merge(ntrg)
	tsg:RemoveCard(c)
	sg:RemoveCard(c)
	return res
end
function Synchro.CheckP42(c,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	local res
	local ntrg=Group.CreateGroup()
	--c has the synchro limit
	if c:IsHasEffect(EFFECT_SYNCHRO_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then return false end
			local sg2=ntg:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			ntrg:Merge(sg2)
		end
	end
	--A card in the selected group has the synchro lmit
	local g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MAT_RESTRICTION)
	for tc in aux.Next(g2) do
		local eff={tc:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then return false end
		end
	end
	if not mgchk then
		if c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then
			local teg={c:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for i=1,#teg do
				local te=teg[i]
				local tgchk=te:GetTarget()
				local res,trg2,ntrg2=tgchk(te,c,sg,Group.CreateGroup(),ntg,tsg,ntsg)
				--if not res then return false end
				if res then
					ntrg:Merge(ntrg2)
					hanchk=true
					break
				end
				if not hanchk then return false end
			end
		end
		g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
		for tc in aux.Next(g2) do
			local eff={tc:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for _,te in ipairs(eff) do
				if te:GetTarget()(te,nil,sg,Group.CreateGroup(),ntg,tsg,ntsg) then
					hanchk=true
					break
				end
			end
			if not hanchk then return false end
		end
	end
	ntg:Sub(ntrg)
	ntsg:AddCard(c)
	sg:AddCard(c)
	local tsg_count=#tsg
	local ntsg_count=#ntsg
	if max and (tsg_count+ntsg_count)>max then
		res = false
	elseif ntsg_count<min2 then
		res=ntg:IsExists(Synchro.CheckP42,1,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max)
	elseif ntsg_count<max2 then
		res=ntg:IsExists(Synchro.CheckP42,1,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,sc,tp,pg,mgchk,min,max) 
			or ((not min or (tsg_count+ntsg_count)>=min) and (not req2 or req2(ntsg,sc,tp)) and (not reqm or reqm(sg,sc,tp)) 
				and sg:Includes(pg) and Synchro.CheckP43(tsg,ntsg,sg,lv,sc,tp))
	else
		res=(not min or (tsg_count+ntsg_count)>=min) and (not req2 or req2(ntsg,sc,tp)) and (not reqm or reqm(sg,sc,tp)) 
			and sg:Includes(pg) and Synchro.CheckP43(tsg,ntsg,sg,lv,sc,tp)
	end
	ntg:Merge(ntrg)
	ntsg:RemoveCard(c)
	sg:RemoveCard(c)
	return res
end
function Synchro.CheckLabel(c,label)
	return c:IsHasEffect(EFFECT_HAND_SYNCHRO) and c:GetCardEffect(EFFECT_HAND_SYNCHRO):GetLabel()==label
end
function Synchro.CheckHand(c,sg)
	if not c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then return false end
	local teg={c:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
	for _,te in ipairs(teg) do
		if sg:IsExists(Synchro.CheckLabel,1,c,te:GetLabel()) then return false end
	end
	return true
end
function Synchro.CheckP43(tsg,ntsg,sg,lv,sc,tp)
	if sg:IsExists(Synchro.CheckHand,1,nil,sg) then return false end
	--[[for c in aux.Next(sg) do
		if c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then
			local teg={c:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for _,te in ipairs(teg) do
				if te:GetTarget()(te,c,sg,Group.CreateGroup(),Group.CreateGroup(),tsg,ntsg) then
					hanchk=true
					break
				end
			end
			if not hanchk then return false end
		end
	end]]
	local lvchk=false
	if sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_MATERIAL_CUSTOM) then
		local g=sg:Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MATERIAL_CUSTOM)
		for tc in aux.Next(g) do
			local teg={tc:GetCardEffect(EFFECT_SYNCHRO_MATERIAL_CUSTOM)}
			for _,te in ipairs(teg) do
				local op=te:GetOperation()
				local ok,tlvchk=op(te,tg,ntg,sg,lv,sc,tp)
				if not ok then return false end
				lvchk=lvchk or tlvchk
			end
		end
	end
	return (lvchk or sg:CheckWithSumEqual(Card.GetSynchroLevel,lv,#sg,#sg,sc))
	and ((sc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,sg,sc)>0)
		or (not sc:IsLocation(LOCATION_EXTRA) and Duel.GetMZoneCount(tp,sg,tp)>0))
end
function Synchro.Target(f1,min1,max1,f2,min2,max2,sub1,sub2,req1,req2,reqm)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg,min,max)
				local sg=Group.CreateGroup()
				local lv=c:GetLevel()
				local mgchk
				local g
				local dg
				if mg then
					mgchk=true
					dg=mg
					g=mg:Filter(Card.IsCanBeSynchroMaterial,c,c)
				else
					mgchk=false
					dg=Duel.GetMatchingGroup(function(mc) return mc:IsFaceup() and (mc:IsControler(tp) or mc:IsCanBeSynchroMaterial(c)) end,tp,LOCATION_MZONE,LOCATION_MZONE,c)
					g=dg:Filter(Card.IsCanBeSynchroMaterial,nil,c)
				end
				local pg=Auxiliary.GetMustBeMaterialGroup(tp,dg,tp,c,g,REASON_SYNCHRO)
				if smat then
					if smat.KeepAlive then
						pg:Merge(smat)
						g:Merge(smat)
					else
						pg:AddCard(smat)
						g:AddCard(smat)
					end
				end
				local tg
				local ntg
				if mgchk then
					tg=g:Filter(Synchro.TunerFilter,nil,f1,sub1,c,tp)
					ntg=g:Filter(Synchro.NonTunerFilter,nil,f2,sub2,c,tp)
				else
					tg=g:Filter(Synchro.TunerFilter,nil,f1,sub1,c,tp)
					ntg=g:Filter(Synchro.NonTunerFilter,nil,f2,sub2,c,tp)
					local thg=tg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO)
					thg:Merge(ntg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO))
					local hg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND+LOCATION_GRAVE,0,c,c)
					for thc in aux.Next(thg) do
						local te=thc:GetCardEffect(EFFECT_HAND_SYNCHRO)
						local val=te:GetValue()
						local thag=hg:Filter(function(mc) return Synchro.TunerFilter(mc,f1,sub1,c,tp) and val(te,mc,c) end,nil) --tuner
						local nthag=hg:Filter(function(mc) return Synchro.NonTunerFilter(mc,f2,sub2,c,tp) and val(te,mc,c) end,nil) --non-tuner
						tg:Merge(thag)
						ntg:Merge(nthag)
					end
				end
				local lv=c:GetLevel()
				local tsg=Group.CreateGroup()
				if g:IsExists(Synchro.CheckFilterChk,1,nil,f1,f2,sub1,sub2,c,tp) then
					local ntsg=Group.CreateGroup()
					local tune=true
					local g2=Group.CreateGroup()
					while #ntsg<max2 do
						local cancel=false
						local finish=false
						if tune then
							cancel=not mgchk and Duel.GetCurrentChain()<=0 and #tsg==0
							local g3=ntg:Filter(Synchro.CheckP32,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							g2=g:Filter(Synchro.CheckP31,sg,g,tsg,ntsg,sg,f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							if #g3>0 and #tsg>=min1 and tsg:IsExists(Synchro.TunerFilter,#tsg,nil,f1,sub1,c,tp) and (not req1 or req1(tsg,c,tp)) then
								g2:Merge(g3)
							end
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
							local tc=Group.SelectUnselect(g2,sg,tp,false,cancel)
							if not tc then
								if #tsg>=min1 and tsg:IsExists(Synchro.TunerFilter,#tsg,nil,f1,sub1,c,tp) and (not req1 or req1(tsg,c,tp))
									and ntg:Filter(Synchro.CheckP32,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max):GetCount()>0 then tune=false
								else
									return false
								end
							end
							if not sg:IsContains(tc) then
								if g3:IsContains(tc) then
									ntsg:AddCard(tc)
									tune = false
								else
									tsg:AddCard(tc)
								end
								sg:AddCard(tc)
								if tc:IsHasEffect(EFFECT_SYNCHRO_CHECK) then
									local teg={tc:GetCardEffect(EFFECT_SYNCHRO_CHECK)}
									for i=1,#teg do
										local te=teg[i]
										local tg=g:Filter(function(mc) return te:GetValue()(te,mc) end,nil)
									end
								end
							else
								tsg:RemoveCard(tc)
								sg:RemoveCard(tc)
								if not sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_CHECK) then
									Duel.AssumeReset()
								end
							end
							if g:FilterCount(Synchro.CheckP31,sg,g,tsg,ntsg,sg,f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)==0 or #tsg>=max2 then
								tune=false
							end
						else
							if (#ntsg>=min2 and (not req2 or req2(ntsg,c,tp)) and (not reqm or reqm(sg,c,tp)) 
								and ntsg:IsExists(Synchro.NonTunerFilter,#ntsg,nil,f2,sub2,c,tp)
								and sg:Includes(pg) and Synchro.CheckP43(tsg,ntsg,sg,lv,c,tp)) then
									finish=true
							end
							cancel = (not mgchk and Duel.GetCurrentChain()<=0) and #sg==0
							g2=g:Filter(Synchro.CheckP32,sg,g,tsg,ntsg,sg,f2,sub2,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							if #g2==0 then break end
							local g3=g:Filter(Synchro.CheckP31,sg,g,tsg,ntsg,sg,f1,sub1,f2,sub2,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							if #g3>0 and #ntsg==0 and #tsg<max1 then
								g2:Merge(g3)
							end
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
							local tc=Group.SelectUnselect(g2,sg,tp,finish,cancel)
							if not tc then
								if #ntsg>=min2 and (not req2 or req2(ntsg,c,tp)) and (not reqm or reqm(sg,c,tp)) 
									and sg:Includes(pg) and Synchro.CheckP43(tsg,ntsg,sg,lv,c,tp) then break end
								return false
							end
							if not tsg:IsContains(tc) then
								if not sg:IsContains(tc) then
									ntsg:AddCard(tc)
									sg:AddCard(tc)
									if tc:IsHasEffect(EFFECT_SYNCHRO_CHECK) then
										local teg={tc:GetCardEffect(EFFECT_SYNCHRO_CHECK)}
										for i=1,#teg do
											local te=teg[i]
											local tg=g:Filter(function(mc) return te:GetValue()(te,mc) end,nil)
										end
									end
								else
									ntsg:RemoveCard(tc)
									sg:RemoveCard(tc)
									if not sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_CHECK) then
										Duel.AssumeReset()
									end
								end
							elseif #ntsg==0 then
								tune=true
								tsg:RemoveCard(tc)
								sg:RemoveCard(tc)
							end
						end
					end
					Duel.AssumeReset()
				else
					local ntsg=Group.CreateGroup()
					local tune=true
					local g2=Group.CreateGroup()
					while #ntsg<max2 do
						local cancel=false
						local finish=false
						if tune then
							cancel=not mgchk and Duel.GetCurrentChain()<=0 and #tsg==0
							local g3=ntg:Filter(Synchro.CheckP42,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							g2=tg:Filter(Synchro.CheckP41,sg,tg,ntg,tsg,ntsg,sg,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							if #g3>0 and #tsg>=min1 and (not req1 or req1(tsg,c,tp)) then
								g2:Merge(g3)
							end
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
							local tc=Group.SelectUnselect(g2,sg,tp,finish,cancel)
							if not tc then
								if #tsg>=min1 and (not req1 or req1(tsg,c,tp))
									and ntg:Filter(Synchro.CheckP42,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max):GetCount()>0 then tune=false
								else
									return false
								end
							else
								if not sg:IsContains(tc) then
									if g3:IsContains(tc) then
										ntsg:AddCard(tc)
										tune = false
									else
										tsg:AddCard(tc)
									end
									sg:AddCard(tc)
								else
									tsg:RemoveCard(tc)
									sg:RemoveCard(tc)
								end
							end
							if tg:FilterCount(Synchro.CheckP41,sg,tg,ntg,tsg,ntsg,sg,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)==0 or #tsg>=max1 then
								tune=false
							end
						else
							if #ntsg>=min2 and (not req2 or req2(ntsg,c,tp)) and (not reqm or reqm(sg,c,tp))
								and sg:Includes(pg) and Synchro.CheckP43(tsg,ntsg,sg,lv,c,tp) then
								finish=true
							end
							cancel=not mgchk and Duel.GetCurrentChain()<=0 and #sg==0
							g2=ntg:Filter(Synchro.CheckP42,sg,ntg,tsg,ntsg,sg,min2,max2,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							if #g2==0 then break end
							local g3=tg:Filter(Synchro.CheckP41,sg,tg,ntg,tsg,ntsg,sg,min1,max1,min2,max2,req1,req2,reqm,lv,c,tp,pg,mgchk,min,max)
							if #g3>0 and #ntsg==0 and #tsg<max1 then
								g2:Merge(g3)
							end
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
							local tc=Group.SelectUnselect(g2,sg,tp,finish,cancel)
							if not tc then
								if #ntsg>=min2 and (not req2 or req2(ntsg,c,tp)) and (not reqm or reqm(sg,c,tp))
									and sg:Includes(pg) and Synchro.CheckP43(tsg,ntsg,sg,lv,c,tp) then break end
								return false
							end
							if not tsg:IsContains(tc) then
								if not sg:IsContains(tc) then
									ntsg:AddCard(tc)
									sg:AddCard(tc)
								else
									ntsg:RemoveCard(tc)
									sg:RemoveCard(tc)
								end
							elseif #ntsg==0 then
								tune=true
								tsg:RemoveCard(tc)
								sg:RemoveCard(tc)
							end
						end
					end
				end
				local hg=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
				aux.ResetEffects(hg,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
				if sg then
					local subtsg=tsg:Filter(function(c) return sub1 and sub1(c) and ((f1 and not f1(c)) or not c:IsType(TYPE_TUNER)) end,nil)
					local subc=subtsg:GetFirst()
					while subc do
						local e1=Effect.CreateEffect(c)
						e1:SetType(EFFECT_TYPE_SINGLE)
						e1:SetCode(EFFECT_ADD_TYPE)
						e1:SetValue(TYPE_TUNER)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD)
						subc:RegisterEffect(e1,true)
						subc=subtsg:GetNext()
					end
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
Synchro.Send=0
function Auxiliary.TatsunecroFilter(c)
	return c:GetFlagEffect(3096468)~=0
end
function Synchro.Operation(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
	local g=e:GetLabelObject()
	c:SetMaterial(g)
	local tg=g:Filter(Auxiliary.TatsunecroFilter,nil)
	if #tg>0 then
		Synchro.Send=2
		for tc in aux.Next(tg) do tc:ResetFlagEffect(3096468) end
	end
	if Synchro.Send==1 then
		Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO+REASON_RETURN)
	elseif Synchro.Send==2 then
		Duel.Remove(g,POS_FACEUP,REASON_MATERIAL+REASON_SYNCHRO)
	elseif Synchro.Send==3 then
		Duel.Remove(g,POS_FACEDOWN,REASON_MATERIAL+REASON_SYNCHRO)
	elseif Synchro.Send==4 then
		Duel.SendtoHand(g,nil,REASON_MATERIAL+REASON_SYNCHRO)
	elseif Synchro.Send==5 then
		Duel.SendtoDeck(g,nil,2,REASON_MATERIAL+REASON_SYNCHRO)
	elseif Synchro.Send==6 then
		Duel.Destroy(g,REASON_MATERIAL+REASON_SYNCHRO)
	else
		Duel.SendtoGrave(g,REASON_MATERIAL+REASON_SYNCHRO)
	end
	Synchro.Send=0
	g:DeleteGroup()
end

--Synchro monster, Majestic
function Synchro.AddMajesticProcedure(c,f1,cbt1,f2,cbt2,f3,cbt3,...)
	--parameters: function, can be tuner, reqm
	if c.synchro_type==nil then
		local mt=c:GetMetatable()
		mt.synchro_type=2
		mt.synchro_parameters={f1,cbt1,f2,cbt2,f3,cbt3,...}
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1172)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Synchro.MajesticCondition(f1,cbt1,f2,cbt2,f3,cbt3,...))
	e1:SetTarget(Synchro.MajesticTarget(f1,cbt1,f2,cbt2,f3,cbt3,...))
	e1:SetOperation(Synchro.Operation)
	e1:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e1)
end
function Synchro.MajesticCheck1(c,g,sg,card1,card2,card3,lv,sc,tp,pg,f1,cbt1,f2,cbt2,f3,cbt3,...)
	local res
	local rg=Group.CreateGroup()
	if c:IsHasEffect(EFFECT_SYNCHRO_CHECK) then
		local teg={c:GetCardEffect(EFFECT_SYNCHRO_CHECK)}
		for i=1,#teg do
			local te=teg[i]
			local val=te:GetValue()
			local tg=g:Filter(function(mc) return val(te,mc) end,nil)
		end
	end
	--c has the synchro limit
	if c:IsHasEffect(EFFECT_SYNCHRO_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then return false end
			local sg1=g:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			rg:Merge(sg1)
		end
	end
	--A card in the selected group has the synchro lmit
	local g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MAT_RESTRICTION)
	for tc in aux.Next(g2) do
		local eff={tc:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then return false end
		end
	end
	if c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then
		local teg={c:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
		local hanchk=false
		for i=1,#teg do
			local te=teg[i]
			local tgchk=te:GetTarget()
			local res,trg,ntrg2=tgchk(te,c,sg,g,g,sg,sg)
			--if not res then return false end
			if res then
				rg:Merge(trg)
				hanchk=true
				break
			end
		end
		if not hanchk then return false end
	end
	g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
	for tc in aux.Next(g2) do
		local eff={tc:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
		local hanchk=false
		for _,te in ipairs(eff) do
			if te:GetTarget()(te,nil,sg,g,g,sg,sg) then
				hanchk=true
				break
			end
		end
		if not hanchk then return false end
	end
	g:Sub(rg)
	sg:AddCard(c)
	if not card1 then
		card1=c
	elseif not card2 then
		card2=c
	else
		card3=c
	end
	if #sg<3 then
		res=g:IsExists(Synchro.MajesticCheck1,1,sg,g,sg,card1,card2,card3,lv,sc,tp,pg,f1,cbt1,f2,cbt2,f3,cbt3,...)
	else
		res=sg:Includes(pg) and Synchro.MajesticCheck2(sg,card1,card2,card3,lv,sc,tp,f1,cbt1,f2,cbt2,f3,cbt3,...)
	end
	g:Merge(rg)
	sg:RemoveCard(c)
	if card3 then
		card3=nil
	elseif card2 then
		card2=nil
	else
		card1=nil
	end
	if not sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_CHECK) then
		Duel.AssumeReset()
	end
	return res
end
function Synchro.MajesticCheck2(sg,card1,card2,card3,lv,sc,tp,f1,cbt1,f2,cbt2,f3,cbt3,...)
	if sg:IsExists(Synchro.CheckHand,1,nil,sg) then return false end
	--[[local c=sg:GetFirst()
	while c do
		if c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then
			local teg={c:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for i=1,#teg do
				local te=teg[i]
				local tgchk=te:GetTarget()
				local res=tgchk(te,c,sg,Group.CreateGroup(),Group.CreateGroup(),Group.CreateGroup(),Group.CreateGroup())
				--if not res then return false end
				if res then
					hanchk=true
					break
				end
			end
			if not hanchk then return false end
		end
		c=sg:GetNext()
	end]]
	local reqm={...}
	local tunechk=false
	if not f1(card1,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp) or not f2(card2,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp) or not f3(card3,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp) then return false end
	if cbt1 and card1:IsType(TYPE_TUNER,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp) then tunechk=true end
	if cbt2 and card2:IsType(TYPE_TUNER,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp) then tunechk=true end
	if cbt3 and card3:IsType(TYPE_TUNER,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp) then tunechk=true end
	if not tunechk then return false end
	local lvchk=false
	for _,reqmat in ipairs(reqm) do
		if not reqmat(sg,sc,tp) then return false end
	end
	if sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_MATERIAL_CUSTOM) then
		local g=sg:Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MATERIAL_CUSTOM)
		for tc in aux.Next(g) do
			local teg={tc:GetCardEffect(EFFECT_SYNCHRO_MATERIAL_CUSTOM)}
			for _,te in ipairs(teg) do
				local op=te:GetOperation()
				local ok,tlvchk=op(te,Group.CreateGroup(),Group.CreateGroup(),sg,lv,sc,tp)
				if not ok then return false end
				lvchk=lvchk or tlvchk
			end
		end
	end
	if not lvchk and not sg:CheckWithSumEqual(Card.GetSynchroLevel,lv,#sg,#sg,sc) then return false end
	if sc:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,sg,sc)>0
	else
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.GetMZoneCount(tp,sg,tp)>0
	end
end
function Synchro.MajesticCondition(f1,cbt1,f2,cbt2,f3,cbt3,...)
	local t={...}
	return	function(e,c,smat,mg,min,max)
				if c==nil then return true end
				if (min and min>3) or (max and max<3) then return false end
				local tp=c:GetControler()
				local lv=c:GetLevel()
				local g
				local mgchk
				local dg
				if mg then
					mgchk=true
					dg=mg
					g=mg:Filter(Card.IsCanBeSynchroMaterial,c,c)
				else
					mgchk=false
					dg=Duel.GetMatchingGroup(function(mc) return mc:IsFaceup() and (mc:IsControler(tp) or mc:IsCanBeSynchroMaterial(c)) end,tp,LOCATION_MZONE,LOCATION_MZONE,c)
					g=dg:Filter(Card.IsCanBeSynchroMaterial,nil,c)
				end
				local pg=Auxiliary.GetMustBeMaterialGroup(tp,dg,tp,c,g,REASON_SYNCHRO)
				if not g:Includes(pg) or pg:IsExists(aux.NOT(Card.IsCanBeSynchroMaterial),1,nil,c) then return false end
				if smat then
					if smat.KeepAlive then
						if smat:IsExists(aux.NOT(Card.IsCanBeSynchroMaterial),1,nil,c) then return false end
						pg:Merge(smat)
						g:Merge(smat)
					else
						if not smat:IsCanBeSynchroMaterial(c) then return false end
						pg:AddCard(smat)
						g:AddCard(smat)
					end
				end
				if not mgchk then
					local thg=g:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO)
					local hg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND+LOCATION_GRAVE,0,c,c)
					for thc in aux.Next(thg) do
						local te=thc:GetCardEffect(EFFECT_HAND_SYNCHRO)
						local val=te:GetValue()
						local ag=hg:Filter(function(mc) return val(te,mc,c) end,nil) --tuner
						g:Merge(ag)
					end
				end
				local res=g:IsExists(Synchro.MajesticCheck1,1,nil,g,Group.CreateGroup(),card1,card2,card3,lv,c,tp,pg,f1,cbt1,f2,cbt2,f3,cbt3,table.unpack(t))
				local hg=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
				aux.ResetEffects(hg,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
				Duel.AssumeReset()
				return res
			end
end
function Synchro.MajesticTarget(f1,cbt1,f2,cbt2,f3,cbt3,...)
	local t={...}
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg,min,max)
				if (min and min>3) or (max and max<3) then return false end
				local sg=Group.CreateGroup()
				local lv=c:GetLevel()
				local mgchk
				local dg
				local g
				if mg then
					mgchk=true
					dg=mg
					g=mg:Filter(Card.IsCanBeSynchroMaterial,c,c)
				else
					mgchk=false
					dg=Duel.GetMatchingGroup(function(mc) return mc:IsFaceup() and (mc:IsControler(tp) or mc:IsCanBeSynchroMaterial(c)) end,tp,LOCATION_MZONE,LOCATION_MZONE,c)
					g=dg:Filter(Card.IsCanBeSynchroMaterial,nil,c)
				end
				local pg=Auxiliary.GetMustBeMaterialGroup(tp,dg,tp,c,g,REASON_SYNCHRO)
				if smat then
					if smat.KeepAlive then
						pg:Merge(smat)
						g:Merge(smat)
					else
						pg:AddCard(smat)
						g:AddCard(smat)
					end
				end
				if not mgchk then
					local thg=g:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO)
					local hg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND+LOCATION_GRAVE,0,c,c)
					for thc in aux.Next(thg) do
						local te=thc:GetCardEffect(EFFECT_HAND_SYNCHRO)
						local val=te:GetValue()
						local ag=hg:Filter(function(mc) return val(te,mc,c) end,nil)
						g:Merge(ag)
					end
				end
				local lv=c:GetLevel()
				local card1=nil
				local card2=nil
				local card3=nil
				local cancel=not mgchk and Duel.GetCurrentChain()<=0
				while #sg<3 do
					local g2=g:Filter(Synchro.MajesticCheck1,sg,g,sg,card1,card2,card3,lv,c,tp,pg,f1,cbt1,f2,cbt2,f3,cbt3,table.unpack(t))
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
					local tc=Group.SelectUnselect(g2,sg,tp,false,cancel)
					if not tc then return false end
					if not sg:IsContains(tc) then
						sg:AddCard(tc)
						if tc:IsHasEffect(EFFECT_SYNCHRO_CHECK) then
							local teg={tc:GetCardEffect(EFFECT_SYNCHRO_CHECK)}
							for i=1,#teg do
								local te=teg[i]
								local tg=g:Filter(function(mc) return te:GetValue()(te,mc) end,nil)
							end
						end
						if not card1 then
							card1=tc
						elseif not card2 then
							card2=tc
						else
							card3=tc
						end
					else
						local rem=false
						if card3 and tc==card3 then
							card3=nil
							rem=true
						elseif not card3 and card2 and tc==card2 then
							card2=nil
							rem=true
						elseif not card3 and not card2 and card1 and tc==card1 then
							card1=nil
							rem=true
						end
						if rem then
							sg:RemoveCard(tc)
							if not sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_CHECK) then
								Duel.AssumeReset()
							end
						end
					end
				end
				Duel.AssumeReset()
				local hg=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
				aux.ResetEffects(hg,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
				if sg then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end

--Dark Synchro monster
function Synchro.AddDarkSynchroProcedure(c,f1,f2,plv,nlv,...)
	--functions, default/dark wave level, reqm
	if c.synchro_type==nil then
		local mt=c:GetMetatable()
		mt.synchro_type=3
		mt.synchro_parameters={f1,f2,plv,nlv,...}
	end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1172)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Synchro.DarkCondition(f1,f2,plv,nlv,...))
	e1:SetTarget(Synchro.DarkTarget(f1,f2,plv,nlv,...))
	e1:SetOperation(Synchro.Operation)
	e1:SetValue(SUMMON_TYPE_SYNCHRO)
	c:RegisterEffect(e1)
end
function Synchro.DarkCheck1(c,g,sg,card1,card2,plv,nlv,sc,tp,pg,f1,f2,...)
	local res
	local rg=Group.CreateGroup()
	if c:IsHasEffect(EFFECT_SYNCHRO_CHECK) then
		local teg={c:GetCardEffect(EFFECT_SYNCHRO_CHECK)}
		for i=1,#teg do
			local te=teg[i]
			local val=te:GetValue()
			local tg=g:Filter(function(mc) return val(te,mc) end,nil)
		end
	end
	--c has the synchro limit
	if c:IsHasEffect(EFFECT_SYNCHRO_MAT_RESTRICTION) then
		local eff={c:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if sg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then return false end
			local sg1=g:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
			rg:Merge(sg1)
		end
	end
	--A card in the selected group has the synchro lmit
	local g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MAT_RESTRICTION)
	for tc in aux.Next(g2) do
		local eff={tc:GetCardEffect(EFFECT_SYNCHRO_MAT_RESTRICTION)}
		for _,f in ipairs(eff) do
			if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then return false end
		end
	end
	if c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then
		local teg={c:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
		local hanchk=false
		for i=1,#teg do
			local te=teg[i]
			local tgchk=te:GetTarget()
			local res,trg,ntrg2=tgchk(te,c,sg,g,g,sg,sg)
			--if not res then return false end
			if res then
				rg:Merge(trg)
				hanchk=true
				break
			end
		end
		if not hanchk then return false end
	end
	g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
	for tc in aux.Next(g2) do
		local eff={tc:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
		local hanchk=false
		for _,te in ipairs(eff) do
			if te:GetTarget()(te,nil,sg,g,g,sg,sg) then
				hanchk=true
				break
			end
		end
		if not hanchk then return false end
	end
	g:Sub(rg)
	sg:AddCard(c)
	if not card1 then
		card1=c
	else
		card2=c
	end
	if #sg<2 then
		res=g:IsExists(Synchro.DarkCheck1,1,sg,g,sg,card1,card2,plv,nlv,sc,tp,pg,f1,f2,...)
	else
		res=sg:Includes(pg) and Synchro.DarkCheck2(sg,card1,card2,plv,nlv,sc,tp,f1,f2,...)
	end
	g:Merge(rg)
	sg:RemoveCard(c)
	if card2 then
		card2=nil
	else
		card1=nil
	end
	if not sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_CHECK) then
		Duel.AssumeReset()
	end
	return res
end
function Synchro.DarkCheck2(sg,card1,card2,plv,nlv,sc,tp,f1,f2,...)
	if sg:IsExists(Synchro.CheckHand,1,nil,sg) then return false end
	--[[local c=sg:GetFirst()
	while c do
		if c:IsHasEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK) then
			local teg={c:GetCardEffect(EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)}
			local hanchk=false
			for i=1,#teg do
				local te=teg[i]
				local tgchk=te:GetTarget()
				local res=tgchk(te,c,sg,Group.CreateGroup(),Group.CreateGroup(),Group.CreateGroup(),Group.CreateGroup())
				--if not res then return false end
				if res then
					hanchk=true
					break
				end
			end
			if not hanchk then return false end
		end
		c=sg:GetNext()
	end]]
	local reqm={...}
	if (f1 and not f1(card1,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp)) or (f2 and not f2(card2,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp)) or not card2:IsType(TYPE_TUNER,sc,SUMMON_TYPE_SYNCHRO|MATERIAL_SYNCHRO,tp) or not card2:IsSetCard(0x600) then return false end
	local lvchk=false
	for _,reqmat in ipairs(reqm) do
		if not reqmat(sg,sc,tp) then return false end
	end
	if sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_MATERIAL_CUSTOM) then
		local g=sg:Filter(Card.IsHasEffect,nil,EFFECT_SYNCHRO_MATERIAL_CUSTOM)
		for tc in aux.Next(g) do
			local teg={tc:GetCardEffect(EFFECT_SYNCHRO_MATERIAL_CUSTOM)}
			for _,te in ipairs(teg) do
				local op=te:GetOperation()
				local ok,tlvchk=op(te,Group.CreateGroup(),Group.CreateGroup(),sg,plv,sc,tp,nlv,card1,card2)
				if not ok then return false end
				lvchk=lvchk or tlvchk
			end
		end
	end
	if sc:IsLocation(LOCATION_EXTRA) then
		if Duel.GetLocationCountFromEx(tp,tp,sg,sc)<=0 then return false end
	else
		if Duel.GetMZoneCount(tp,sg,tp)<=0 then return false end
	end
	if lvchk then return true end
	local ntlv=card1:GetSynchroLevel(sc)
	local ntlv1=ntlv&0xffff
	local ntlv2=ntlv>>16
	local tlv=card2:GetSynchroLevel(sc)
	local tlv1=tlv&0xffff
	local tlv2=tlv>>16
	if card1:GetFlagEffect(100000147)>0 then
		if tlv1==nlv-ntlv1 then return true end
		if (tlv2>0 or card2:IsStatus(STATUS_NO_LEVEL)) and (ntlv2>0 or card1:IsStatus(STATUS_NO_LEVEL)) then
			return tlv2==nlv-ntlv1 or tlv1==nlv-ntlv2 or tlv2==nlv-ntlv2
		elseif tlv2>0 or card2:IsStatus(STATUS_NO_LEVEL) then
			return tlv2==nlv-ntlv1
		elseif ntlv2>0 or card1:IsStatus(STATUS_NO_LEVEL) then
			return tlv1==nlv-ntlv2
		end
		return false
	else
		if tlv1==plv+ntlv1 then return true end
		if (tlv2>0 or card2:IsStatus(STATUS_NO_LEVEL)) and (ntlv2>0 or card1:IsStatus(STATUS_NO_LEVEL)) then
			return tlv2==plv+ntlv1 or tlv1==plv+ntlv2 or tlv2==plv+ntlv2
		elseif tlv2>0 or card2:IsStatus(STATUS_NO_LEVEL) then
			return tlv2==nlv-ntlv1
		elseif ntlv2>0 or card1:IsStatus(STATUS_NO_LEVEL) then
			return tlv1==nlv-ntlv2
		end
		return false
	end
end
function Synchro.DarkCondition(f1,f2,plv,nlv,...)
	local t={...}
	return	function(e,c,smat,mg,min,max)
				if c==nil then return true end
				if (min and min>2) or (max and max<2) then return false end
				local plv=plv
				local nlv=nlv
				if plv==nil then
					plv=c:GetLevel()
				end
				if nlv==nil then
					nlv=plv
				end
				local tp=c:GetControler()
				local g
				local mgchk
				local dg
				if mg then
					mgchk=true
					dg=mg
					g=mg:Filter(Card.IsCanBeSynchroMaterial,c,c)
				else
					mgchk=false
					dg=Duel.GetMatchingGroup(function(mc) return mc:IsFaceup() and (mc:IsControler(tp) or mc:IsCanBeSynchroMaterial(c)) end,tp,LOCATION_MZONE,LOCATION_MZONE,c)
					g=dg:Filter(Card.IsCanBeSynchroMaterial,nil,c)
				end
				local pg=Auxiliary.GetMustBeMaterialGroup(tp,dg,tp,c,g,REASON_SYNCHRO)
				if not g:Includes(pg) or pg:IsExists(aux.NOT(Card.IsCanBeSynchroMaterial),1,nil,c) then return false end
				if smat then
					if smat.KeepAlive then
						if smat:IsExists(aux.NOT(Card.IsCanBeSynchroMaterial),1,nil,c) then return false end
						pg:Merge(smat)
						g:Merge(smat)
					else
						if not smat:IsCanBeSynchroMaterial(c) then return false end
						pg:AddCard(smat)
						g:AddCard(smat)
					end
				end
				if not mgchk then
					local thg=g:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO)
					local hg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND+LOCATION_GRAVE,0,c,c)
					for thc in aux.Next(thg) do
						local te=thc:GetCardEffect(EFFECT_HAND_SYNCHRO)
						local val=te:GetValue()
						local ag=hg:Filter(function(mc) return val(te,mc,c) end,nil) --tuner
						g:Merge(ag)
					end
				end
				local res=g:IsExists(Synchro.DarkCheck1,1,nil,g,Group.CreateGroup(),card1,card2,plv,nlv,c,tp,pg,f1,f2,table.unpack(t))
				local hg=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
				aux.ResetEffects(hg,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
				Duel.AssumeReset()
				return res
			end
end
function Synchro.DarkTarget(f1,f2,plv,nlv,...)
	local t={...}
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,smat,mg,min,max)
				if (min and min>2) or (max and max<2) then return false end
				local sg=Group.CreateGroup()
				local plv=plv
				local nlv=nlv
				if plv==nil then
					plv=c:GetLevel()
				end
				if nlv==nil then
					nlv=plv
				end
				local mgchk
				local g
				local dg
				if mg then
					mgchk=true
					dg=mg
					g=mg:Filter(Card.IsCanBeSynchroMaterial,c,c)
				else
					mgchk=false
					dg=Duel.GetMatchingGroup(function(mc) return mc:IsFaceup() and (mc:IsControler(tp) or mc:IsCanBeSynchroMaterial(c)) end,tp,LOCATION_MZONE,LOCATION_MZONE,c)
					g=dg:Filter(Card.IsCanBeSynchroMaterial,nil,c)
				end
				local pg=Auxiliary.GetMustBeMaterialGroup(tp,dg,tp,c,g,REASON_SYNCHRO)
				if smat then
					if smat.KeepAlive then
						pg:Merge(smat)
						g:Merge(smat)
					else
						pg:AddCard(smat)
						g:AddCard(smat)
					end
				end
				if not mgchk then
					local thg=g:Filter(Card.IsHasEffect,nil,EFFECT_HAND_SYNCHRO)
					local hg=Duel.GetMatchingGroup(Card.IsCanBeSynchroMaterial,tp,LOCATION_HAND+LOCATION_GRAVE,0,c,c)
					for thc in aux.Next(thg) do
						local te=thc:GetCardEffect(EFFECT_HAND_SYNCHRO)
						local val=te:GetValue()
						local ag=hg:Filter(function(mc) return val(te,mc,c) end,nil)
						g:Merge(ag)
					end
				end
				local lv=c:GetLevel()
				local card1=nil
				local card2=nil
				local cancel=not mgchk and Duel.GetCurrentChain()<=0
				while #sg<2 do
					local g2=g:Filter(Synchro.DarkCheck1,sg,g,sg,card1,card2,plv,nlv,c,tp,pg,f1,f2,table.unpack(t))
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SMATERIAL)
					local tc=Group.SelectUnselect(g2,sg,tp,false,cancel)
					if not tc then return false end
					if not sg:IsContains(tc) then
						sg:AddCard(tc)
						if tc:IsHasEffect(EFFECT_SYNCHRO_CHECK) then
							local teg={tc:GetCardEffect(EFFECT_SYNCHRO_CHECK)}
							for i=1,#teg do
								local te=teg[i]
								local tg=g:Filter(function(mc) return te:GetValue()(te,mc) end,nil)
							end
						end
						if not card1 then
							card1=tc
						else
							card2=tc
						end
					else
						local rem=false
						if card2 and tc==card2 then
							card2=nil
							rem=true
						elseif not card2 and card1 and tc==card1 then
							card1=nil
							rem=true
						end
						if rem then
							sg:RemoveCard(tc)
							if not sg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SYNCHRO_CHECK) then
								Duel.AssumeReset()
							end
						end
					end
				end
				Duel.AssumeReset()
				local hg=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
				aux.ResetEffects(hg,EFFECT_HAND_SYNCHRO+EFFECT_SYNCHRO_CHECK)
				if sg then
					sg:KeepAlive()
					e:SetLabelObject(sg)
					return true
				else return false end
			end
end
