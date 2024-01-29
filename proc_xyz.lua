if not aux.XyzProcedure then
	aux.XyzProcedure = {}
	Xyz = aux.XyzProcedure
end
if not Xyz then
	Xyz = aux.XyzProcedure
end
Xyz.ProcCancellable=false
function Xyz.EffectXyzMaterialChk(c,xyz,tp)
	local eff_xyzmat={c:GetCardEffect(EFFECT_XYZ_MATERIAL)}
	for _,eff in ipairs(eff_xyzmat) do
		local val=eff:GetValue()
		if val==0 or val(eff,c,xyz,tp) then return true end
	end
	return false
end
function Xyz.AlterFilter(c,alterf,xyzc,e,tp,op)
	if not alterf(c,tp,xyzc) or not c:IsCanBeXyzMaterial(xyzc,tp)
		or (c:IsControler(1-tp) and not Xyz.EffectXyzMaterialChk(c,xyzc,tp))
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
end
--Xyz Summon(normal)
function Xyz.MatFilter2(c,f,lv,xyz,tp)
	if f and not f(c,xyz,SUMMON_TYPE_XYZ|MATERIAL_XYZ,tp) then return false end
	if lv and not c:IsXyzLevel(xyz,lv) then return false end
	return c:IsCanBeXyzMaterial(xyz,tp)
end
function Xyz.GetMaterials(tp,xyz)
	return Duel.GetMatchingGroup(function(c)
		if c:IsLocation(LOCATION_GRAVE) and not c:IsHasEffect(EFFECT_XYZ_MAT_FROM_GRAVE) then return false end
		if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return false end
		return (c:IsControler(tp) or Xyz.EffectXyzMaterialChk(c,xyz,tp))
	end,tp,LOCATION_MZONE|LOCATION_GRAVE,LOCATION_MZONE,nil)
end
function Xyz.MatFilter(c,f,lv,xyz,tp)
	return (c:IsControler(tp) or Xyz.EffectXyzMaterialChk(c,xyz,tp)) and Xyz.MatFilter2(c,f,lv,xyz,tp)
end
function Xyz.SubMatFilter(c,lv,xyz,tp)
	if not lv then return false end
	local te=c:GetCardEffect(EFFECT_SPELL_XYZ_MAT)
	if not te then return false end
	local f=te:GetValue()
	if type(f)=='function' then
		if f(te)~=lv then return false end
	else
		if f~=lv then return false end
	end
	return true
end
function Xyz.CheckValidMultiXyzMaterial(c,xyz)
	local eff={c:GetCardEffect(EFFECT_DOUBLE_XYZ_MATERIAL)}
	for i,te in ipairs(eff) do
		local tgf=te:GetOperation()
		if not tgf or tgf(te,xyz) then return true end
	end
	return false
end
function Xyz.CheckMaterialSet(matg,xyz,tp,exchk,mustg,lv)
	if not matg:Includes(mustg) then return false end
	if matg:IsExists(Card.IsHasEffect,1,nil,EFFECT_STAR_SERAPH_SOVEREIGNTY) and not Xyz.MatNumChkF(matg) then
		return false
	end
	if lv and matg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SATELLARKNIGHT_CAPELLA) and not Xyz.MatNumChkF2(matg,lv,xyz) then
		return false
	end
	if exchk and #matg>0 and not exchk(matg,tp,xyz) then
		return false
	end
	if xyz:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,matg,xyz)>0
	else
		return Duel.GetMZoneCount(tp,matg,tp)>0
	end
end
function Xyz.RecursionChk1(c,mg,xyz,tp,min,max,minc,maxc,sg,matg,ct,matct,mustbemat,exchk,f,mustg,lv)
	local xct=ct
	local rg=Group.CreateGroup()
	if not c:IsHasEffect(EFFECT_ORICHALCUM_CHAIN) then
		xct=xct+1
	end
	local xmatct=matct+1
	for i,f in ipairs({c:GetCardEffect(EFFECT_XYZ_MAT_RESTRICTION)}) do
		if matg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then
			mg:Merge(rg)
			return false
		end
		local sg2=mg:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
		rg:Merge(sg2)
		mg:Sub(sg2)
	end
	for tc in matg:Iter() do
		for i,f in ipairs({tc:GetCardEffect(EFFECT_XYZ_MAT_RESTRICTION)}) do
			if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then
				mg:Merge(rg)
				return false
			end
		end
	end
	if xct>max or xmatct>maxc then mg:Merge(rg) return false end
	local addToMatg=not c:IsHasEffect(EFFECT_ORICHALCUM_CHAIN)
	if addToMatg then
		matg:AddCard(c)
	end
	sg:AddCard(c)
	local res=(function()
		if (xct>=min) and (xmatct>=minc) and Xyz.CheckMaterialSet(matg,xyz,tp,exchk,mustg,lv) then return true end
		if mg:IsExists(Xyz.RecursionChk1,1,sg,mg,xyz,tp,min,max,minc,maxc,sg,matg,xct,xmatct,mustbemat,exchk,f,mustg,lv) then return true end
		if not mustbemat then
			local retchknum={}
			for i,te in ipairs({c:GetCardEffect(EFFECT_DOUBLE_XYZ_MATERIAL)}) do
				local tgf=te:GetOperation()
				local val=te:GetValue()
				if val>0 and not retchknum[val] and (not tgf or tgf(te,xyz)) then
					local res2=false
					if xct>=min and xmatct+val>=minc and xct<=max and xmatct+val<=maxc then
						res2=Xyz.CheckMaterialSet(matg,xyz,tp,exchk,mustg,lv)
					end
					if xmatct+val<=maxc then
						retchknum[val]=true
						if res2 or mg:IsExists(Xyz.RecursionChk1,1,sg,mg,xyz,tp,min,max,minc,maxc,sg,matg,xct,xmatct+val,mustbemat,exchk,f,mustg,lv) then return true end
					end
				end
			end
		end
		return false
	end)()
	if addToMatg then
		matg:RemoveCard(c)
	end
	sg:RemoveCard(c)
	mg:Merge(rg)
	return res
end
function Xyz.RecursionChk2(c,mg,xyz,tp,minc,maxc,sg,matg,ct,mustbemat,exchk,f,mustg,lv)
	if c:IsHasEffect(EFFECT_EQUIP_SPELL_XYZ_MAT) and not sg:IsContains(c:GetEquipTarget()) then return false end
	local rg=Group.CreateGroup()
	local xct=ct+1
	for i,f in ipairs({c:GetCardEffect(EFFECT_XYZ_MAT_RESTRICTION)}) do
		if matg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then
			mg:Merge(rg)
			return false
		end
		local sg2=mg:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
		rg:Merge(sg2)
		mg:Sub(sg2)
	end
	for tc in sg:Iter() do
		for i,f in ipairs({tc:GetCardEffect(EFFECT_XYZ_MAT_RESTRICTION)}) do
			if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then
				mg:Merge(rg)
				return false
			end
		end
	end
	if xct>maxc then mg:Merge(rg) return false end
	local addToMatg=not c:IsHasEffect(EFFECT_EQUIP_SPELL_XYZ_MAT) and not c:IsHasEffect(EFFECT_ORICHALCUM_CHAIN)
	if addToMatg then
		matg:AddCard(c)
	end
	sg:AddCard(c)
	local eqg=nil
	local res=(function()
		if (xct>=minc) and Xyz.CheckMaterialSet(matg,xyz,tp,exchk,mustg,lv) then return true end
		if not mustbemat then
			eqg=c:GetEquipGroup():Filter(Card.IsHasEffect,nil,EFFECT_EQUIP_SPELL_XYZ_MAT)
			mg:Merge(eqg)
		end
		if mg:IsExists(Xyz.RecursionChk2,1,sg,mg,xyz,tp,minc,maxc,sg,matg,xct,mustbemat,exchk,f,mustg,lv) then return true end
		if not mustbemat then
			local retchknum={}
			for i,te in ipairs({c:GetCardEffect(EFFECT_DOUBLE_XYZ_MATERIAL)}) do
				local tgf=te:GetOperation()
				local val=te:GetValue()
				if val>0 and (not tgf or tgf(te,xyz)) and not retchknum[val] then
					local res2=false
					if xct+val>=minc and xct+val<=maxc then
						res2=Xyz.CheckMaterialSet(matg,xyz,tp,exchk,mustg,lv)
					end
					if xct+val<=maxc then
						retchknum[val]=true
						if res2 or mg:IsExists(Xyz.RecursionChk2,1,sg,mg,xyz,tp,minc,maxc,sg,matg,xct+val,mustbemat,exchk,f,mustg,lv) then return true end
					end
				end
			end
		end
		return false
	end)()
	if addToMatg then
		matg:RemoveCard(c)
	end
	sg:RemoveCard(c)
	if eqg then
		mg:Sub(eqg)
	end
	mg:Merge(rg)
	return res
end
function Xyz.MatNumChkF(tg)
	local chkg=tg:Filter(Card.IsHasEffect,nil,EFFECT_STAR_SERAPH_SOVEREIGNTY)
	for chkc in aux.Next(chkg) do
		for _,te in ipairs({chkc:GetCardEffect(EFFECT_STAR_SERAPH_SOVEREIGNTY)}) do
			local rct=te:GetValue()&0xffff
			local comp=te:GetValue()>>16
			if not Xyz.MatNumChk(tg:FilterCount(Card.IsMonster,nil),rct,comp) then return false end
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
	local chkg=tg:Filter(Card.IsHasEffect,nil,EFFECT_SATELLARKNIGHT_CAPELLA)
	for chkc in aux.Next(chkg) do
		local rev={}
		for _,te in ipairs({chkc:GetCardEffect(EFFECT_SATELLARKNIGHT_CAPELLA)}) do
			local rct=te:GetValue()&0xffff
			local comp=te:GetValue()>>16
			if not Xyz.MatNumChk(tg:FilterCount(Card.IsMonster,nil),rct,comp) then
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
	return not f or f(e,c) or c:IsHasEffect(EFFECT_ORICHALCUM_CHAIN) or c:IsHasEffect(EFFECT_EQUIP_SPELL_XYZ_MAT)
end
function Xyz.Condition(f,lv,minc,maxc,mustbemat,exchk)
	--og: use specific material
	return  function(e,c,must,og,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local mg
				local g
				if og then
					g=og
					mg=og:Filter(Xyz.MatFilter,nil,f,lv,c,tp)
				else
					g=Xyz.GetMaterials(tp,c)
					mg=g:Filter(Xyz.MatFilter2,nil,f,lv,c,tp)
					if not mustbemat then
						local eqmg=Group.CreateGroup()
						for tc in aux.Next(mg) do
							local eq=tc:GetEquipGroup():Filter(Card.IsHasEffect,nil,EFFECT_EQUIP_SPELL_XYZ_MAT)
							eqmg:Merge(eq)
						end
						mg:Merge(eqmg)
						if not f then
							mg:Merge(Duel.GetMatchingGroup(Xyz.SubMatFilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,lv,c,tp))
						end
					end
				end
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_XYZ)
				if must then mustg:Merge(must) end
				if not mg:Includes(mustg) then return false end
				if not mustbemat then
					mg:Merge(Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,EFFECT_ORICHALCUM_CHAIN))
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
					if (#og>=minc and #og<=maxc) or not og:IsExists(Card.IsHasEffect,1,nil,EFFECT_ORICHALCUM_CHAIN) then
						e:SetLabelObject(og:Clone():KeepAlive())
						return true
					else
						local tab={}
						local ct,matct,min,max=0,0,#og,#og
						local matg=Group.CreateGroup()
						local sg=Group.CreateGroup()
						local mg=og+Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,EFFECT_ORICHALCUM_CHAIN)
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
								if sc:IsHasEffect(EFFECT_ORICHALCUM_CHAIN) then
									matct=matct+1
								elseif sc:IsHasEffect(EFFECT_DOUBLE_XYZ_MATERIAL) then
									matg:AddCard(sc)
									ct=ct+1
									if not Xyz.CheckValidMultiXyzMaterial(sc,c) or (min>=ct and minc>=matct+1) then
										matct=matct+1
									else
										local multi={}
										if mg:IsExists(Xyz.RecursionChk1,1,sg,mg,c,tp,min,max,minc,maxc,sg,matg,ct,matct+1,mustbemat,exchk,f,mustg,lv) then
											table.insert(multi,1)
										end
										local eff={sc:GetCardEffect(EFFECT_DOUBLE_XYZ_MATERIAL)}
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
											Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
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
								if sc:IsHasEffect(EFFECT_ORICHALCUM_CHAIN) then
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
					local cancel=not og and Duel.IsSummonCancelable()
					local mg
					if og then
						g=og
						mg=og:Filter(Xyz.MatFilter,nil,f,lv,c,tp)
					else
						g=Xyz.GetMaterials(tp,c)
						mg=g:Filter(Xyz.MatFilter2,nil,f,lv,c,tp)
						if not mustbemat then
							local eqmg=Group.CreateGroup()
							for tc in aux.Next(mg) do
								local eq=tc:GetEquipGroup():Filter(Card.IsHasEffect,nil,EFFECT_EQUIP_SPELL_XYZ_MAT)
								eqmg:Merge(eq)
							end
							mg:Merge(eqmg)
							if not f then
								mg:Merge(Duel.GetMatchingGroup(Xyz.SubMatFilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil,lv,c,tp))
							end
						end
					end
					local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_XYZ)
					if must then mustg:Merge(must) end
					if not mustbemat then
						mg:Merge(Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,EFFECT_ORICHALCUM_CHAIN))
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
								if ct<minc or (matg:IsExists(Card.IsHasEffect,1,nil,EFFECT_STAR_SERAPH_SOVEREIGNTY) and not Xyz.MatNumChkF(matg))
									or (lv and matg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SATELLARKNIGHT_CAPELLA) and not Xyz.MatNumChkF2(matg,lv,c)) then return false end
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
								mg:Merge(sc:GetEquipGroup():Filter(Card.IsHasEffect,nil,EFFECT_EQUIP_SPELL_XYZ_MAT))
								if not sc:IsHasEffect(EFFECT_ORICHALCUM_CHAIN) then
									matg:AddCard(sc)
								end
								ct=ct+1
								if Xyz.CheckValidMultiXyzMaterial(sc,c) and ct<minc then
									local multi={}
									if mg:IsExists(Xyz.RecursionChk2,1,sg,mg,c,tp,minc,maxc,sg,matg,ct,mustbemat,exchk,f,mustg,lv) then
										table.insert(multi,1)
									end
									local eff={sc:GetCardEffect(EFFECT_DOUBLE_XYZ_MATERIAL)}
									for i=1,#eff do
										local te=eff[i]
										local tgf=te:GetOperation()
										local val=te:GetValue()
										if val>0 and (not tgf or tgf(te,c)) then
											if minc<=ct+val and ct+val<=maxc
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
										Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
										local num=Duel.AnnounceNumber(tp,table.unpack(multi))
										if num>1 then
											ct=ct+num-1
											tab[sc]=num
										end
									end
								end
							else
								sg:RemoveCard(sc)
								mg:Sub(sc:GetEquipGroup():Filter(Card.IsHasEffect,nil,EFFECT_EQUIP_SPELL_XYZ_MAT))
								if not sc:IsHasEffect(EFFECT_ORICHALCUM_CHAIN) then
									matg:RemoveCard(sc)
								end
								ct=ct-1
								if tab[sc] then
									ct=ct-tab[sc]+1
									tab[sc]=nil
								end
							end
							if ct>=minc and (not matg:IsExists(Card.IsHasEffect,1,nil,EFFECT_STAR_SERAPH_SOVEREIGNTY) or Xyz.MatNumChkF(matg))
								and (not lv or not matg:IsExists(Card.IsHasEffect,1,nil,EFFECT_SATELLARKNIGHT_CAPELLA) or Xyz.MatNumChkF2(matg,lv,c)) and matg:Includes(mustg) then
								finish=true
							end
							cancel=not og and Duel.IsSummonCancelable() and #sg==0
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
	return  function(e,tp,eg,ep,ev,re,r,rp,c,must,og,min,max)
				local g=e:GetLabelObject()
				if not g then return end
				local remg=g:Filter(Card.IsHasEffect,nil,EFFECT_ORICHALCUM_CHAIN)
				remg:ForEach(function(c) c:RegisterFlagEffect(511002115,RESET_EVENT+RESETS_STANDARD,0,0) end)
				g:Remove(Card.IsHasEffect,nil,EFFECT_ORICHALCUM_CHAIN):Remove(Card.IsHasEffect,nil,511002115)
				c:SetMaterial(g)
				Duel.Overlay(c,g,true)
				g:DeleteGroup()
			end
end
--Xyz summon(alterf)
function Xyz.Condition2(alterf,op)
	return  function(e,c,must,og,min,max)
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
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,og,min,max)
				local cancel=not og and Duel.IsSummonCancelable()
				Xyz.ProcCancellable=cancel
				if og and not min then
					e:SetLabelObject(og:GetFirst())
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
	return  function(e,tp,eg,ep,ev,re,r,rp,c,must,og,min,max)
				local oc=e:GetLabelObject()
				c:SetMaterial(oc)
				Duel.Overlay(c,oc)
			end
end
