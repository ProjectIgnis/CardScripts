if not aux.XyzProcedure then
	aux.XyzProcedure = {}
	Xyz = aux.XyzProcedure
end
if not Xyz then
	Xyz = aux.XyzProcedure
end
function Xyz.AlterFilter(c,alterf,xyzc,e,tp,op)
	if not alterf(c,tp,xyzc) or not c:IsCanBeXyzMaterial(xyzc,tp) or (c:IsControler(1-tp) and not c:IsHasEffect(EFFECT_XYZ_MATERIAL)) 
		or (op and not op(e,tp,0,c)) then return false end
	if xyzc:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,c,xyzc)>0
	else
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or c:GetSequence()<5
	end
end
--Xyz monster, lv k*n
function Xyz.AddProcedure(c,f,lv,ct,alterf,desc,maxct,op,mustbemat,exchk)
	--exchk for special xyz, checking other materials
	--mustbemat for Startime Magician
	if not maxct then maxct=ct end	
	if c.xyz_filter==nil then
		local mt=c:GetMetatable()
		mt.xyz_filter=function(mc,ignoretoken,xyz,tp) return mc and (not f or f(mc,xyz,SUMMON_TYPE_XYZ|MATERIAL_XYZ,tp)) and (not lv or mc:IsXyzLevel(c,lv)) and (not mc:IsType(TYPE_TOKEN) or ignoretoken) end
		mt.xyz_parameters={mt.xyz_filter,lv,ct,alterf,desc,maxct,op,mustbemat,exchk}
		mt.minxyzct=ct
		mt.maxxyzct=maxct
	end
	
	local chk1=Effect.CreateEffect(c)
	chk1:SetType(EFFECT_TYPE_SINGLE)
	chk1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	chk1:SetCode(946)
	chk1:SetCondition(Xyz.Condition(f,lv,ct,maxct,mustbemat,exchk))
	chk1:SetTarget(Xyz.Target(f,lv,ct,maxct,mustbemat,exchk))
	chk1:SetOperation(Xyz.Operation(f,lv,ct,maxct,mustbemat,exchk))
	c:RegisterEffect(chk1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1173)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(Xyz.Condition(f,lv,ct,maxct,mustbemat,exchk))
	e1:SetTarget(Xyz.Target(f,lv,ct,maxct,mustbemat,exchk))
	e1:SetOperation(Xyz.Operation(f,lv,ct,maxct,mustbemat,exchk))
	e1:SetValue(SUMMON_TYPE_XYZ)
	e1:SetLabelObject(chk1)
	c:RegisterEffect(e1)
	if alterf then
		local chk2=chk1:Clone()
		chk2:SetDescription(desc)
		chk2:SetCondition(Xyz.Condition2(alterf,op))
		chk2:SetTarget(Xyz.Target2(alterf,op))
		chk2:SetOperation(Xyz.Operation2(alterf,op))
		c:RegisterEffect(chk2)
		local e2=e1:Clone()
		e2:SetDescription(desc)
		e2:SetCondition(Xyz.Condition2(alterf,op))
		e2:SetTarget(Xyz.Target2(alterf,op))
		e2:SetOperation(Xyz.Operation2(alterf,op))
		c:RegisterEffect(e2)
	end
	
	if not xyztemp then
		xyztemp=true
		xyztempg0=Group.CreateGroup()
		xyztempg0:KeepAlive()
		xyztempg1=Group.CreateGroup()
		xyztempg1:KeepAlive()
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
		e3:SetCode(EVENT_ADJUST)
		e3:SetCountLimit(1)
		e3:SetOperation(Xyz.MatGenerate)
		Duel.RegisterEffect(e3,0)
	end
end
function Xyz.MatGenerate(e,tp,eg,ep,ev,re,r,rp)
	local tck0=Duel.CreateToken(0,946)
	xyztempg0:AddCard(tck0)
	local tck1=Duel.CreateToken(1,946)
	xyztempg1:AddCard(tck1)
end
--Xyz Summon(normal)
function Xyz.MatFilter2(c,f,lv,xyz,tp)
	if c:IsLocation(LOCATION_GRAVE) and not c:IsHasEffect(511002793) then return false end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return false end
	return Xyz.MatFilter(c,f,lv,xyz,tp)
end
function Xyz.MatFilter(c,f,lv,xyz,tp)
	return (not f or f(c,xyz,SUMMON_TYPE_XYZ|MATERIAL_XYZ,tp)) and (not lv or c:IsXyzLevel(xyz,lv)) and c:IsCanBeXyzMaterial(xyz,tp) 
		and (c:IsControler(tp) or c:IsHasEffect(EFFECT_XYZ_MATERIAL))
end
function Xyz.SubMatFilter(c,fil,lv,xg,xyz,tp)
	if not lv then return false end
	--Solid Overlay-type
	local te=c:GetCardEffect(511000189)
	if not te then return false end
	local f=te:GetValue()
	if type(f)=='function' then
		if f(te)~=lv then return false end
	else
		if f~=lv then return false end
	end
	return xg:IsExists(Xyz.SubFilterChk,1,nil,fil,xyz,tp)
end
function Xyz.SubFilterChk(c,f,xyz,tp)
	return (not f or f(c,xyz,SUMMON_TYPE_XYZ|MATERIAL_XYZ,tp))
end
function Xyz.CheckValidMultiXyzMaterial(c,xyz)
	if not c:IsHasEffect(511001225) then return false end
	local eff={c:GetCardEffect(511001225)}
	for i=1,#eff do
		local te=eff[i]
		local tgf=te:GetOperation()
		if not tgf or tgf(te,xyz) then return true end
	end
	return false
end
function Xyz.RecursionChk1(c,mg,xyz,tp,min,max,minc,maxc,sg,matg,ct,matct,mustbemat,exchk,f,mustg,lv)
	local xct=ct
	local rg=Group.CreateGroup()
	if not c:IsHasEffect(511002116) then
		xct=xct+1
	end
	local xmatct=matct+1
	local eff={c:GetCardEffect(EFFECT_XYZ_MAT_RESTRICTION)}
	for i,f in ipairs(eff) do
		if matg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then
			mg:Merge(rg)
			return false
		end
		local sg2=mg:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
		rg:Merge(sg2)
		mg:Sub(sg2)
	end
	local g2=matg:Filter(Card.IsHasEffect,nil,EFFECT_XYZ_MAT_RESTRICTION)
	if #g2>0 then
		local tc=g2:GetFirst()
		while tc do
			local eff={tc:GetCardEffect(EFFECT_XYZ_MAT_RESTRICTION)}
			for i,f in ipairs(eff) do
				if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then
					mg:Merge(rg)
					return false
				end
			end
			tc=g2:GetNext()
		end	
	end
	if xct>max or xmatct>maxc then mg:Merge(rg) return false end
	if not c:IsHasEffect(511002116) then
		matg:AddCard(c)
	end
	sg:AddCard(c)
	local res=nil
	if xct>=min and xmatct>=minc then
		local ok=true
		if matg:IsExists(Card.IsHasEffect,1,nil,91110378) then
			ok=Xyz.MatNumChkF(matg)
		end
		if lv and ok and matg:IsExists(Card.IsHasEffect,1,nil,86466163) then
			ok=Xyz.MatNumChkF2(matg,lv,xyz)
		end
		if ok and exchk then
			if #matg>0 and not exchk(matg,tp,xyz) then ok=false end
		end
		if not matg:Includes(mustg) then ok=false end
		if ok then
			if xyz:IsLocation(LOCATION_EXTRA) then
				res = Duel.GetLocationCountFromEx(tp,tp,matg,xyz)>0
			else
				res = Duel.GetMZoneCount(tp,matg,tp)>0
			end
		end
	end
	local retchknum={0}
	local retchk={mg:IsExists(Xyz.RecursionChk1,1,sg,mg,xyz,tp,min,max,minc,maxc,sg,matg,xct,xmatct,mustbemat,exchk,f,mustg,lv)}
	if not res and c:IsHasEffect(511001225) and not mustbemat then
		local eff={c:GetCardEffect(511001225)}
		for i,te in ipairs(eff) do
			local tgf=te:GetOperation()
			local val=te:GetValue()
			local redun=false
			for _,v in ipairs(retchknum) do
				if v==val then redun=true break end
			end	
			if not redun and val>0 and (not tgf or tgf(te,xyz)) then
				if xct>=min and xmatct+val>=minc and xct<=max and xmatct+val<=maxc then
					local ok=true
					if matg:IsExists(Card.IsHasEffect,1,nil,91110378) then
						ok=Xyz.MatNumChkF(matg)
					end
					if lv and ok and matg:IsExists(Card.IsHasEffect,1,nil,86466163) then
						ok=Xyz.MatNumChkF2(matg,lv,xyz)
					end
					if ok and exchk then
						if #matg>0 and not exchk(matg,tp,xyz) then ok=false end
					end
					if not matg:Includes(mustg) then ok=false end
					if ok then
						if xyz:IsLocation(LOCATION_EXTRA) then
							res = Duel.GetLocationCountFromEx(tp,tp,matg,xyz)>0
						else
							res = Duel.GetMZoneCount(tp,matg,tp)>0
						end
					end
				end
				if xmatct+val<=maxc then
					table.insert(retchknum,val)
					table.insert(retchk,mg:IsExists(Xyz.RecursionChk1,1,sg,mg,xyz,tp,min,max,minc,maxc,sg,matg,xct,xmatct+val,mustbemat,exchk,f,mustg,lv))
				end
			end
		end
	end
	for i=1,#retchk do
		if retchk[i] then res=true break end
	end
	matg:RemoveCard(c)
	sg:RemoveCard(c)
	mg:Merge(rg)
	return res
end
function Xyz.RecursionChk2(c,mg,xyz,tp,minc,maxc,sg,matg,ct,mustbemat,exchk,f,mustg,lv)
	local rg=Group.CreateGroup()
	if c:IsHasEffect(511001175) and not sg:IsContains(c:GetEquipTarget()) then return false end
	local xct=ct+1
	local eff={c:GetCardEffect(EFFECT_XYZ_MAT_RESTRICTION)}
	for i,f in ipairs(eff) do
		if matg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then
			mg:Merge(rg)
			return false
		end
		local sg2=mg:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
		rg:Merge(sg2)
		mg:Sub(sg2)
	end
	local g2=sg:Filter(Card.IsHasEffect,nil,EFFECT_XYZ_MAT_RESTRICTION)
	if #g2>0 then
		local tc=g2:GetFirst()
		while tc do
			local eff={tc:GetCardEffect(EFFECT_XYZ_MAT_RESTRICTION)}
			for i,f in ipairs(eff) do
				if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then
					mg:Merge(rg)
					return false
				end
			end
			tc=g2:GetNext()
		end
	end
	if xct>maxc then mg:Merge(rg) return false end
	if not c:IsHasEffect(511001175) and not c:IsHasEffect(511002116) then
		matg:AddCard(c)
	end
	sg:AddCard(c)
	local res=nil
	if xct>=minc then
		local ok=true
		if matg:IsExists(Card.IsHasEffect,1,nil,91110378) then
			ok=Xyz.MatNumChkF(matg)
		end
		if lv and ok and matg:IsExists(Card.IsHasEffect,1,nil,86466163) then
			ok=Xyz.MatNumChkF2(matg,lv,xyz)
		end
		if ok and exchk then
			if #matg>0 and not exchk(matg,tp,xyz) then ok=false end
		end
		if not matg:Includes(mustg) then ok=false end
		if ok then
			if xyz:IsLocation(LOCATION_EXTRA) then
				res = Duel.GetLocationCountFromEx(tp,tp,matg,xyz)>0
			else
				res = Duel.GetMZoneCount(tp,matg,tp)>0
			end
		end
	end
	local eqg=Group.CreateGroup()
	if not mustbemat then
		eqg:Merge(c:GetEquipGroup():Filter(Card.IsHasEffect,nil,511001175))
		mg:Merge(eqg)
	end
	local retchknum={0}
	local retchk={mg:IsExists(Xyz.RecursionChk2,1,sg,mg,xyz,tp,minc,maxc,sg,matg,xct,mustbemat,exchk,f,mustg,lv)}
	if not res and c:IsHasEffect(511001225) and not mustbemat then
		local eff={c:GetCardEffect(511001225)}
		for i,te in ipairs(eff) do
			local tgf=te:GetOperation()
			local val=te:GetValue()
			local redun=false
			for _,v in ipairs(retchknum) do
				if v==val then redun=true break end
			end
			if val>0 and (not tgf or tgf(te,xyz)) and not redun then
				if xct+val>=minc and xct+val<=maxc then
					local ok=true
					if matg:IsExists(Card.IsHasEffect,1,nil,91110378) then
						ok=Xyz.MatNumChkF(matg)
					end
					if lv and ok and matg:IsExists(Card.IsHasEffect,1,nil,86466163) then
						ok=Xyz.MatNumChkF2(matg,lv,xyz)
					end
					if ok and exchk then
						if #matg>0 and not exchk(matg,tp,xyz) then ok=false end
					end
					if not matg:Includes(mustg) then ok=false end
					if ok then
						if xyz:IsLocation(LOCATION_EXTRA) then
							res = Duel.GetLocationCountFromEx(tp,tp,matg,xyz)>0
						else
							res = Duel.GetMZoneCount(tp,matg,tp)>0
						end
					end
				end
				if xct+val<=maxc then
					retchknum[#retchknum+1]=val
					retchk[#retchk+1]=mg:IsExists(Xyz.RecursionChk2,1,sg,mg,xyz,tp,minc,maxc,sg,matg,xct+val,mustbemat,exchk,f,mustg,lv)
				end
			end
		end
	end
	for i=1,#retchk do
		if retchk[i] then res=true break end
	end
	matg:RemoveCard(c)
	sg:RemoveCard(c)
	mg:Sub(eqg)
	mg:Merge(rg)
	return res
end
function Xyz.MatNumChkF(tg)
	local chkg=tg:Filter(Card.IsHasEffect,nil,91110378)
	for chkc in aux.Next(chkg) do
		for _,te in ipairs({chkc:GetCardEffect(91110378)}) do
			local rct=te:GetValue()&0xffff
			local comp=te:GetValue()>>16
			if not Xyz.MatNumChk(tg:FilterCount(Card.IsType,nil,TYPE_MONSTER),rct,comp) then return false end
		end
	end
	return true
end
function Xyz.MatNumChk(matct,ct,comp)
	local ok=false
	if not ok and comp&0x1==0x1 and matct>ct then ok=true end
	if not ok and comp&0x2==0x2 and matct==ct then ok=true end
	if not ok and comp&0x4==0x4 and matct<ct then ok=true end
	return ok
end
function Xyz.MatNumChkF2(tg,lv,xyz)
	local chkg=tg:Filter(Card.IsHasEffect,nil,86466163)
	for chkc in aux.Next(chkg) do
		local rev={}
		for _,te in ipairs({chkc:GetCardEffect(86466163)}) do
			local rct=te:GetValue()&0xffff
			local comp=te:GetValue()>>16
			if not Xyz.MatNumChk(tg:FilterCount(Card.IsType,nil,TYPE_MONSTER),rct,comp) then
				local con=te:GetLabelObject():GetCondition()
				if not con then con=aux.TRUE end
				if not rev[te] then
					table.insert(rev,te)
					rev[te]=con
					te:GetLabelObject():SetCondition(aux.FALSE)
				end
			end
		end
		if #rev>0 then
			local islv=chkc:IsXyzLevel(xyz,lv)
			for _,te in ipairs(rev) do
				local con=rev[te]
				te:GetLabelObject():SetCondition(con)
			end
			if not islv then return false end
		end
	end
	return true
end
function Auxiliary.HarmonizingMagFilterXyz(c,e,f)
	return not f or f(e,c) or c:IsHasEffect(511002116) or c:IsHasEffect(511001175)
end
function Xyz.Condition(f,lv,minc,maxc,mustbemat,exchk)
	--og: use special material
	return	function(e,c,must,og,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local xg=nil
				if tp==0 then
					xg=xyztempg0
				else
					xg=xyztempg1
				end
				if not xg or #xg==0 then return false end
				local mg
				local g
				if og then
					g=og
					mg=og:Filter(Xyz.MatFilter,nil,f,lv,c,tp)
				else
					g=Duel.GetMatchingGroup(function(c) return ((c:IsLocation(LOCATION_GRAVE) and c:IsHasEffect(511002793)) 
						or c:IsFaceup()) and (c:IsControler(tp) or c:IsHasEffect(EFFECT_XYZ_MATERIAL)) end,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE,nil)
					mg=Duel.GetMatchingGroup(Xyz.MatFilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE,nil,f,lv,c,tp)
					if not mustbemat then
						local eqmg=Group.CreateGroup()
						for tc in aux.Next(mg) do
							local eq=tc:GetEquipGroup():Filter(Card.IsHasEffect,nil,511001175)
							eqmg:Merge(eq)
						end
						mg:Merge(eqmg)
						mg:Merge(Duel.GetMatchingGroup(Xyz.SubMatFilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,f,lv,xg,c,tp))
					end
				end
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_XYZ)
				if must then mustg:Merge(must) end
				if not mg:Includes(mustg) then return false end
				if not mustbemat then
					mg:Merge(Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,511002116))
				end
				if min and min~=99 then
					return mg:IsExists(Xyz.RecursionChk1,1,nil,mg,c,tp,min,max,minc,maxc,Group.CreateGroup(),Group.CreateGroup(),0,0,mustbemat,exchk,f,mustg,lv)
				else
					return mg:IsExists(Xyz.RecursionChk2,1,nil,mg,c,tp,minc,maxc,Group.CreateGroup(),Group.CreateGroup(),0,mustbemat,exchk,f,mustg,lv)
				end
				return false
			end
end
function Xyz.Target(f,lv,minc,maxc,mustbemat,exchk)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,og,min,max)
				if og and not min then
					if (#og>=minc and #og<=maxc) or not og:IsExists(Card.IsHasEffect,1,nil,511002116) then
						og:KeepAlive()
						e:SetLabelObject(og)
						return true
					else
						local tab={}
						local ct,matct,min,max=0,0,#og,#og
						local matg=Group.CreateGroup()
						local sg=Group.CreateGroup()
						local mg=og:Clone()
						mg:Merge(Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,511002116))
						local finish=false
						while ct<max and matct<maxc do
							local selg=mg:Filter(Xyz.RecursionChk1,sg,mg,c,tp,min,max,minc,maxc,sg,matg,ct,matct,mustbemat,exchk,f,mustg,lv)
							if #selg<=0 then break end
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
							local sc=Group.SelectUnselect(selg,sg,tp,finish)
							if not sc then break end
							if ct>=min and matct>=maxc then finish=true end
							if not sg:IsContains(sc) then
								sg:AddCard(sc)
								if sc:IsHasEffect(511002116) then
									matct=matct+1
								elseif sc:IsHasEffect(511001225) then
									matg:AddCard(sc)
									ct=ct+1
									if not Xyz.CheckValidMultiXyzMaterial(sc,c) or (min>=ct and minc>=matct+1) then
										matct=matct+1
									else
										local multi={}
										if mg:IsExists(Xyz.RecursionChk1,1,sg,mg,c,tp,min,max,minc,maxc,sg,matg,ct,matct+1,mustbemat,exchk,f,mustg,lv) then
											table.insert(multi,1)
										end
										local eff={sc:GetCardEffect(511001225)}
										for i=1,#eff do
											local te=eff[i]
											local tgf=te:GetOperation()
											local val=te:GetValue()
											if val>0 and (not tgf or tgf(te,c)) then
												if (min>=ct and minc>=matct+1+val) 
													or mg:IsExists(Xyz.RecursionChk1,1,sg,mg,c,tp,min,max,minc,maxc,sg,matg,ct,matct+1+val,mustbemat,exchk,f,mustg,lv) then
													table.insert(multi,1+val)
												end
											end
										end
										if #multi==1 then
											tab[sc]=multi[1]
											matct=matct+multi[1]
										else
											Duel.Hint(HINT_SELECTMSG,tp,513)
											local num=Duel.AnnounceNumber(tp,table.unpack(multi))
											tab[sc]=num
											matct=matct+num
										end
									end
								else
									matg:AddCard(sc)
									ct=ct+1
									matct=matct+1
								end
							else
								sg:RemoveCard(sc)
								if sc:IsHasEffect(511002116) then
									matct=matct-1
								else
									matg:RemoveCard(sc)
									ct=ct-1
									local num=tab[sc]
									if num then
										tab[sc]=nil
										matct=matct-num
									else
										matct=matct-1
									end
								end
							end
						end
						sg:KeepAlive()
						e:SetLabelObject(sg)
						return true
					end
					--end of part 1
				else
					local cancel=not og and Duel.GetCurrentChain()<=0
					local xg=nil
					if tp==0 then
						xg=xyztempg0
					else
						xg=xyztempg1
					end
					local mg
					if og then
						g=og
						mg=og:Filter(Xyz.MatFilter,nil,f,lv,c,tp)
					else
						g=Duel.GetMatchingGroup(function(c) return ((c:IsLocation(LOCATION_GRAVE) and c:IsHasEffect(511002793)) 
							or c:IsFaceup()) and (c:IsControler(tp) or c:IsHasEffect(EFFECT_XYZ_MATERIAL)) end,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE,nil)
						mg=Duel.GetMatchingGroup(Xyz.MatFilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE,nil,f,lv,c,tp)
						if not mustbemat then
							local eqmg=Group.CreateGroup()
							for tc in aux.Next(mg) do
								local eq=tc:GetEquipGroup():Filter(Card.IsHasEffect,nil,511001175)
								eqmg:Merge(eq)
							end
							mg:Merge(eqmg)
							mg:Merge(Duel.GetMatchingGroup(Xyz.SubMatFilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,f,lv,xg,c,tp))
						end
					end
					local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_XYZ)
					if must then mustg:Merge(must) end
					if not mustbemat then
						mg:Merge(Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,511002116))
					end
					local finish=false
					if not og or max==99 then
						local ct=0
						local matg=Group.CreateGroup()
						local sg=Group.CreateGroup()
						local tab={}
						while ct<maxc do
							local tg=mg:Filter(Xyz.RecursionChk2,sg,mg,c,tp,minc,maxc,sg,matg,ct,mustbemat,exchk,f,mustg,lv)
							if #tg==0 then break end
							Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
							local sc=Group.SelectUnselect(tg,sg,tp,finish,cancel)
							if not sc then
								if #matg<minc or (matg:IsExists(Card.IsHasEffect,1,nil,91110378) and not Xyz.MatNumChkF(matg)) 
									or (lv and matg:IsExists(Card.IsHasEffect,1,nil,86466163) and not Xyz.MatNumChkF2(matg,lv,c)) then return false end
								if not matg:Includes(mustg) then return false end
								if c:IsLocation(LOCATION_EXTRA) then
									if Duel.GetLocationCountFromEx(tp,tp,matg,c)<1 then return false end
								else
									if Duel.GetMZoneCount(tp,matg,tp)<1 then return false end
								end
								break
							end
							if not sg:IsContains(sc) then
								sg:AddCard(sc)
								mg:Merge(sc:GetEquipGroup():Filter(Card.IsHasEffect,nil,511001175))
								if not sc:IsHasEffect(511002116) then
									matg:AddCard(sc)
								end
								ct=ct+1
								if Xyz.CheckValidMultiXyzMaterial(sc,c) and ct<minc then
									local multi={}
									if mg:IsExists(Xyz.RecursionChk2,1,sg,mg,c,tp,minc,maxc,sg,matg,ct,mustbemat,exchk,f,mustg,lv) then
										table.insert(multi,1)
									end
									local eff={sc:GetCardEffect(511001225)}
									for i=1,#eff do
										local te=eff[i]
										local tgf=te:GetOperation()
										local val=te:GetValue()
										if val>0 and (not tgf or tgf(te,c)) then
											if minc>=ct+val 
												or mg:IsExists(Xyz.RecursionChk2,1,sg,mg,c,tp,minc,maxc,sg,matg,ct+val,mustbemat,exchk,f,mustg,lv) then
												table.insert(multi,1+val)
											end
										end
									end
									if #multi==1 then
										if multi[1]>1 then
											ct=ct+multi[1]-1
											tab[sc]=multi[1]
										end
									else
										Duel.Hint(HINT_SELECTMSG,tp,513)
										local num=Duel.AnnounceNumber(tp,table.unpack(multi))
										if num>1 then
											ct=ct+num-1
											tab[sc]=num
										end
									end
								end
							else
								sg:RemoveCard(sc)
								mg:Sub(sc:GetEquipGroup():Filter(Card.IsHasEffect,nil,511001175))
								if not sc:IsHasEffect(511002116) then
									matg:RemoveCard(sc)
								end
								ct=ct-1
								if tab[sc] then
									ct=ct-tab[sc]+1
									tab[sc]=nil
								end
							end
							if ct>=minc and (not matg:IsExists(Card.IsHasEffect,1,nil,91110378) or Xyz.MatNumChkF(matg)) 
								and (not lv or not matg:IsExists(Card.IsHasEffect,1,nil,86466163) or Xyz.MatNumChkF2(matg,lv,c)) and matg:Includes(mustg) then
								finish=true
							end
							cancel=not og and Duel.GetCurrentChain()<=0 and #sg==0
						end
						sg:KeepAlive()
						e:SetLabelObject(sg)
						return true
					end
					return false
				end
			end
end
function Xyz.Operation(f,lv,minc,maxc,mustbemat,exchk)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,must,og,min,max)
				local g=e:GetLabelObject()
				if not g then return end
				local remg=g:Filter(Card.IsHasEffect,nil,511002116)
				remg:ForEach(function(c) c:RegisterFlagEffect(511002115,RESET_EVENT+RESETS_STANDARD,0,0) end)
				g:Remove(Card.IsHasEffect,nil,511002116)
				g:Remove(Card.IsHasEffect,nil,511002115)
				local sg=Group.CreateGroup()
				for tc in aux.Next(g) do
					local sg1=tc:GetOverlayGroup()
					sg:Merge(sg1)
				end
				Duel.SendtoGrave(sg,REASON_RULE)
				c:SetMaterial(g)
				Duel.Overlay(c,g:Filter(function(c) return c:GetEquipTarget() end,nil))
				Duel.Overlay(c,g)
				g:DeleteGroup()
			end
end
--Xyz summon(alterf)
function Xyz.Condition2(alterf,op)
	return	function(e,c,must,og,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local mg=nil
				if og then
					mg=og
				else
					mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
				end
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,og,tp,c,mg,REASON_XYZ)
				if must then mustg:Merge(must) end
				if #mustg>1 or (min and min>1) or not mg:Includes(mustg) then return false end
				local mustc=mustg:GetFirst()
				if mustc then
					return Xyz.AlterFilter(mustc,alterf,c,e,tp,op)
				else
					return mg:IsExists(Xyz.AlterFilter,1,nil,alterf,c,e,tp,op)
				end
			end
end
function Xyz.Target2(alterf,op)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,og,min,max)
				local cancel=not og and Duel.GetCurrentChain()<=0
				Auxiliary.ProcCancellable=cancel
				if og and not min then
					og:KeepAlive()
					e:SetLabelObject(og)
					if op then op(e,tp,1,og:GetFirst()) end
					return true
				else
					local mg=nil
					if og then
						mg=og
					else
						mg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
					end
					local mustg=Auxiliary.GetMustBeMaterialGroup(tp,og,tp,c,mg,REASON_XYZ)
					if must then mustg:Merge(must) end
					local oc
					if #mustg>0 then
						oc=mustg:GetFirst()
					else
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
						oc=mg:Filter(Xyz.AlterFilter,nil,alterf,c,e,tp,op):SelectUnselect(Group.CreateGroup(),tp,false,cancel)
					end
					if not oc then return false end
					local ok=true
					if op then ok=op(e,tp,1,oc) end
					if not ok then return false end
					e:SetLabelObject(oc)
					return true
				end
			end
end	
function Xyz.Operation2(alterf,op)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,must,og,min,max)
				local oc=e:GetLabelObject()
				local mg2=oc:GetOverlayGroup()
				if #mg2~=0 then
					Duel.Overlay(c,mg2)
				end
				c:SetMaterial(Group.FromCards(oc))
				Duel.Overlay(c,oc)
			end
end
