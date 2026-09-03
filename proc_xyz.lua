if not aux.XyzProcedure then
	aux.XyzProcedure = {}
	Xyz = aux.XyzProcedure
end
if not Xyz then
	Xyz = aux.XyzProcedure
end
local infToken={}
Xyz.InfiniteMats=infToken
Xyz.ProcCancellable=false
Xyz.CheckAdditional=nil
EFFECT_GALAXY_WIZARD = 511600442
EFFECT_GAGAGA_MIRAGE = 511600443

function Xyz.EffectXyzMaterialChk(c,xyz,tp)
	local eff_xyzmat={c:GetCardEffect(EFFECT_XYZ_MATERIAL)}
	for _,eff in ipairs(eff_xyzmat) do
		local val=eff:GetValue()
		if val==0 or val(eff,c,xyz,tp) then return true end
	end
	return false
end
--Xyz monster, lv k*n
function Xyz.AddProcedure(c,f,lv,ct,alterf,desc,maxct,op,mustbemat,exchk)
	--exchk for special xyz, checking other materials
	--mustbemat for Startime Magician
	if not maxct then maxct=ct end
	if maxct==99 then
		maxct=Xyz.InfiniteMats
		Debug.PrintStacktrace()
		Debug.Message("Using 99 to represent any number of Xyz materials is deprecated, use the value Xyz.InfiniteMats instead")
	end
	if c.xyz_filter==nil then
		local mt=c:GetMetatable()
		mt.xyz_filter=function(mc,ignoretoken,xyz,tp) return mc and (not f or f(mc,xyz,SUMMON_TYPE_XYZ|MATERIAL_XYZ,tp)) and (not lv or mc:IsXyzLevel(c,lv)) and (not mc:IsType(TYPE_TOKEN) or ignoretoken) end
		mt.xyz_parameters={mt.xyz_filter,lv,ct,alterf,desc,maxct,op,mustbemat,exchk}
		mt.minxyzct=ct
		mt.maxxyzct=maxct
	end

	local chk1=Effect.CreateEffect(c)
	chk1:SetType(EFFECT_TYPE_SINGLE)
	chk1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE)
	chk1:SetCode(946)
	chk1:SetCondition(Xyz.Condition(f,lv,ct,maxct,mustbemat,exchk))
	chk1:SetTarget(Xyz.Target(f,lv,ct,maxct,mustbemat,exchk))
	chk1:SetOperation(Xyz.Operation(f,lv,ct,maxct,mustbemat,exchk))
	c:RegisterEffect(chk1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(1173)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
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
		e2:SetLabelObject(chk2)
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
function Xyz.GalaxyWizardChk(c,f,lv,xyz,tp)
	if not c:IsHasEffect(EFFECT_GALAXY_WIZARD) then return false end
	if not c:IsCanBeXyzMaterial(xyz,tp) or (f and not f(c,xyz,SUMMON_TYPE_XYZ|MATERIAL_XYZ,tp)) then return false end
	if c:IsControler(1-tp) and not Xyz.EffectXyzMaterialChk(c,xyz,tp) then return false end
	return lv and c:IsLevel(lv-4) and c:IsXyzLevel(xyz,lv-4)
end
function Xyz.SubMatFilter(c,lv,xyz,tp)
	if not lv then return false end
	local effs={c:GetCardEffect(EFFECT_SPELL_XYZ_MAT)}
	for _,te in ipairs(effs) do
		local val=te:GetValue()
		if (type(val)=='function' and val(te,c,lv,xyz,tp)==lv) or val==lv then return true end
	end
	return false
end
function Xyz.CheckValidMultiXyzMaterial(effs,xyz,matg)
	for i,te in ipairs(effs) do
		local tgf=te:GetOperation()
		if not tgf or tgf(te,xyz,matg) then return true end
	end
	return false
end
function Xyz.MatNumChk(matct,ct,comp)
	if (comp&0x1)==0x1 and matct>ct then return true end
	if (comp&0x2)==0x2 and matct==ct then return true end
	if (comp&0x4)==0x4 and matct<ct then return true end
	return false
end
function Xyz.MatNumChkF(tg)
	for chkc in tg:Iter() do
		for _,te in ipairs({chkc:GetCardEffect(EFFECT_STAR_SERAPH_SOVEREIGNTY)}) do
			local rct=te:GetValue()&0xffff
			local comp=(te:GetValue()>>16)&0xffff
			if not Xyz.MatNumChk(tg:FilterCount(Card.IsMonster,nil),rct,comp) then return false end
		end
	end
	return true
end
function Xyz.MatNumChkF2(tg,lv,xyz)
	for chkc in tg:Iter() do
		local rev={}
		for _,te in ipairs({chkc:GetCardEffect(EFFECT_SATELLARKNIGHT_CAPELLA)}) do
			local rct=te:GetValue()&0xffff
			local comp=(te:GetValue()>>16)&0xffff
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
function Xyz.CheckMaterialSet(matg,xyz,tp,exchk,mustg,lv,min,max,gmg,Double,finale)
	if not matg:Includes(mustg) then return false end
	if #matg<min or (max and #matg>max) then return false end
	if not Xyz.MatNumChkF(matg) or (lv and not Xyz.MatNumChkF2(matg,lv,xyz)) then return false end
	local ignored=#(gmg&matg)>0
	if exchk and #matg>0 and not exchk(matg,tp,xyz) then
		if not matg:IsExists(Card.IsHasEffect,1,nil,EFFECT_GAGAGA_MIRAGE) then return false end
		xyz:RegisterFlagEffect(EFFECT_GAGAGA_MIRAGE,0,0,0) --Rilliona & Longlong
		for matc in matg:Iter() do
			matc:AssumeProperty(ASSUME_RACE,0xfffffff)
			matc:AssumeProperty(ASSUME_ATTRIBUTE,0x7f)
		end
		local exres=exchk(matg,tp,xyz)
		xyz:ResetFlagEffect(EFFECT_GAGAGA_MIRAGE)
		Duel.AssumeReset()
		if not exres then return false end
		ignored=true
	end
	if ignored and Double==0 then return false end
	if Xyz.CheckAdditional and not Xyz.CheckAdditional(matg,xyz,tp,lv) then return false end
	if xyz:IsLocation(LOCATION_EXTRA) then
		if Duel.GetLocationCountFromEx(tp,tp,matg,xyz)<1 then return false end
	else
		if Duel.GetMZoneCount(tp,matg,tp)<1 then return false end
	end
	if finale then return true,ignored end
	return true
end
function Xyz.RecursionChk(c,mg,xyz,tp,min,max,minc,maxc,sg,matg,ct,matct,mustbemat,exchk,f,mustg,lv,eqmg,equips_inverse,gwg,gmg,Double)
	local addToMatg=true
	if eqmg and eqmg:IsContains(c) then
		if not sg:IsContains(c:GetEquipTarget()) then return false end
	end
	local xct=ct
	local rg=Group.CreateGroup()
	if not c:IsHasEffect(EFFECT_ORICHALCUM_CHAIN) then
		xct=xct+1
	else
		addToMatg=false
	end
	local xmatct=matct+1
	local gwp,gwf,gwv=gwg:IsContains(c),false,0
	if gwp then
		gwv=c:GetCardEffect(EFFECT_GALAXY_WIZARD):GetValue()
		if not c:IsXyzLevel(xyz,lv) then
			gwf=true
			xmatct=xmatct+gwv
		end
	end
	local gmf,ignored=false,#(gmg&(matg+c))>0
	if Double==0 and ignored then
		if maxc~=infToken then
			if gwf then
				if (max and xct+1>max) or xmatct+2>maxc then mg:Merge(rg) return false end
			else
				if xmatct+1==maxc then
					if not c:IsHasEffect(EFFECT_GAGAGA_MIRAGE) then mg:Merge(rg) return false end
					gmf=true
					Double=Double+1
					xmatct=xmatct+1
				end
			end
		else
			if not mg:IsExists(Card.IsHasEffect,1,matg+c,EFFECT_GAGAGA_MIRAGE) then
				if not c:IsHasEffect(EFFECT_GAGAGA_MIRAGE) or gwf then mg:Merge(rg) return false end
				gmf=true
				Double=Double+1
				xmatct=xmatct+1
			end
		end
	end
	if (max and xct>max) or (maxc~=infToken and xmatct>maxc) then mg:Merge(rg) return false end
	for i,f in ipairs({c:GetCardEffect(EFFECT_XYZ_MAT_RESTRICTION)}) do
		if matg:IsExists(Auxiliary.HarmonizingMagFilter,1,c,f,f:GetValue()) then mg:Merge(rg) return false end
		local sg2=mg:Filter(Auxiliary.HarmonizingMagFilter,nil,f,f:GetValue())
		rg:Merge(sg2)
		mg:Sub(sg2)
	end
	for tc in sg:Iter() do
		for i,f in ipairs({tc:GetCardEffect(EFFECT_XYZ_MAT_RESTRICTION)}) do
			if Auxiliary.HarmonizingMagFilter(c,f,f:GetValue()) then mg:Merge(rg) return false end
		end
	end
	if addToMatg then matg:AddCard(c) end
	sg:AddCard(c)
	local eqg=nil
	local res=(function()
		local function chkset(db) return Xyz.CheckMaterialSet(matg,xyz,tp,exchk,mustg,lv,min,max,gmg,db) end
		local function checkother(n1,n2,db) return mg:IsExists(Xyz.RecursionChk,1,sg,mg,xyz,tp,min,max,minc,maxc,sg,matg,n1,n2,mustbemat,exchk,f,mustg,lv,eqmg,equips_inverse,gwg,gmg,db) end
		if xmatct>=minc and chkset(Double) then return true end
		if equips_inverse then
			eqg=equips_inverse[c]
			if eqg then mg:Merge(eqg) end
		end
		if checkother(xct,xmatct,Double) then return true end
		if mustbemat then return false end
		if gwf or gmf then return (xmatct>=minc and chkset(Double)) or checkother(xct,xmatct,Double) end
		if gwp and (not maxc or maxc==infToken or xmatct+gwv<=maxc) then
			if (xmatct+gwv>=minc and chkset(Double)) or checkother(xct,xmatct+gwv,Double) then return true end
		end
		local retchknum={}
		for i,te in ipairs({c:IsHasEffect(EFFECT_DOUBLE_XYZ_MATERIAL,tp)}) do
			local tgf,val=te:GetOperation(),te:GetValue()
			if val>0 and not retchknum[val] and (not maxc or maxc==infToken or xmatct+val<=maxc) and (not tgf or tgf(te,xyz,matg)) then
				retchknum[val]=true
				te:UseCountLimit(tp)
				local double_plus=Double
				if c:IsHasEffect(EFFECT_GAGAGA_MIRAGE) and val==1 then double_plus=double_plus+1 end
				local chk=(xmatct+val>=minc and chkset(double_plus)) or checkother(xct,xmatct+val,double_plus)
				te:RestoreCountLimit(tp)
				if chk then return true end
			end
		end
		return false
	end)()
	if addToMatg then matg:RemoveCard(c) end
	sg:RemoveCard(c)
	if eqg then mg:Sub(eqg) end
	mg:Merge(rg)
	return res
end
function Auxiliary.HarmonizingMagFilterXyz(c,e,f)
	return not f or f(e,c) or c:IsHasEffect(EFFECT_ORICHALCUM_CHAIN) or c:IsHasEffect(EFFECT_EQUIP_SPELL_XYZ_MAT)
end
function Xyz.Condition(f,lv,minc,maxc,mustbemat,exchk)
	--og: use specific material
	return function(e,c,must,og,min,max)
				if c==nil then return true end
				if (maxc~=infToken and min and min>maxc) then return false end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local g,mg,eqmg,equips_inverse
				local gwg,gmg=Group.CreateGroup(),Group.CreateGroup()
				if og then
					g=og
					mg=g:Filter(Xyz.MatFilter,nil,f,lv,c,tp)
				else
					g=Xyz.GetMaterials(tp,c)
					mg=g:Filter(Xyz.MatFilter2,nil,f,lv,c,tp)
				end
				if not mustbemat then
					gwg=g:Filter(Xyz.GalaxyWizardChk,nil,f,lv,c,tp)
					mg:Merge(gwg)
					if g:IsExists(Card.IsHasEffect,1,nil,EFFECT_GAGAGA_MIRAGE) then
						local invg=g-mg
						for invc in invg:Iter() do
							invc:AssumeProperty(ASSUME_RACE,0xfffffff)
							invc:AssumeProperty(ASSUME_ATTRIBUTE,0x7f)
						end
						if og then
							gmg=invg:Filter(Xyz.MatFilter,nil,f,lv,c,tp)
						else
							gmg=invg:Filter(Xyz.MatFilter2,nil,f,lv,c,tp)
						end
						gwg:Merge(invg:Filter(Xyz.GalaxyWizardChk,nil,f,lv,c,tp))
						gmg:Merge(invg:Filter(Xyz.GalaxyWizardChk,nil,f,lv,c,tp))
						Duel.AssumeReset()
						mg:Merge(gwg):Merge(gmg)
					end
					if not og then
						for tc in aux.Next(mg) do
							local eq=tc:GetEquipGroup():Filter(Card.IsHasEffect,nil,EFFECT_EQUIP_SPELL_XYZ_MAT)
							if #eq~=0 then
								if not equips_inverse then
									eqmg=Group.CreateGroup()
									equips_inverse={}
								end
								equips_inverse[tc]=eq
								eqmg:Merge(eq)
							end
						end
						if eqmg then mg:Merge(eqmg) end
						if not f then mg:Merge(Duel.GetMatchingGroup(Xyz.SubMatFilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,nil,lv,c,tp)) end
					end
				end
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_XYZ)
				if must then mustg:Merge(must) end
				if not mg:Includes(mustg) then return false end
				if not mustbemat then
					mg:Merge(Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED,0,nil,EFFECT_ORICHALCUM_CHAIN))
				end
				min=min or 0
				return mg:IsExists(Xyz.RecursionChk,1,nil,mg,c,tp,min,max,minc,maxc,Group.CreateGroup(),Group.CreateGroup(),0,0,mustbemat,exchk,f,mustg,lv,eqmg,equips_inverse,gwg,gmg,0)
			end
end
function Xyz.Target(f,lv,minc,maxc,mustbemat,exchk)
	return function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,og,min,max)
				local g,mg,eqmg,equips_inverse
				local gwg,gmg=Group.CreateGroup(),Group.CreateGroup()
				if og then
					g=og
					mg=g:Filter(Xyz.MatFilter,nil,f,lv,c,tp)
				else
					g=Xyz.GetMaterials(tp,c)
					mg=g:Filter(Xyz.MatFilter2,nil,f,lv,c,tp)
				end
				if not mustbemat then
					gwg=g:Filter(Xyz.GalaxyWizardChk,nil,f,lv,c,tp)
					mg:Merge(gwg)
					if g:IsExists(Card.IsHasEffect,1,nil,EFFECT_GAGAGA_MIRAGE) then
						local invg=g-mg
						for invc in invg:Iter() do
							invc:AssumeProperty(ASSUME_RACE,0xfffffff)
							invc:AssumeProperty(ASSUME_ATTRIBUTE,0x7f)
						end
						if og then
							gmg=invg:Filter(Xyz.MatFilter,nil,f,lv,c,tp)
						else
							gmg=invg:Filter(Xyz.MatFilter2,nil,f,lv,c,tp)
						end
						gwg:Merge(invg:Filter(Xyz.GalaxyWizardChk,nil,f,lv,c,tp))
						gmg:Merge(invg:Filter(Xyz.GalaxyWizardChk,nil,f,lv,c,tp))
						Duel.AssumeReset()
						mg:Merge(gwg):Merge(gmg)
					end
					if not og then
						for tc in aux.Next(mg) do
							local eq=tc:GetEquipGroup():Filter(Card.IsHasEffect,nil,EFFECT_EQUIP_SPELL_XYZ_MAT)
							if #eq~=0 then
								if not equips_inverse then
									eqmg=Group.CreateGroup()
									equips_inverse={}
								end
								equips_inverse[tc]=eq
								eqmg:Merge(eq)
							end
						end
						if eqmg then mg:Merge(eqmg) end
						if not f then mg:Merge(Duel.GetMatchingGroup(Xyz.SubMatFilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,nil,lv,c,tp)) end
					end
				end
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_XYZ)
				if must then mustg:Merge(must) end
				if not mustbemat then
					mg:Merge(Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED,0,nil,EFFECT_ORICHALCUM_CHAIN))
				end
				do
					local extra_mats=0
					min=min or 0
					local matg=Group.CreateGroup()
					local sg=Group.CreateGroup()
					local multiXyzSelectedCards={}
					local gwCards,gmCards={},{}
					local Double=0
					local finishable=false
					while true do
						local ct=#matg
						local matct=ct+extra_mats
						if (max and ct>max) or (maxc~=infToken and matct>=maxc) then break end
						local selg=mg:Filter(Xyz.RecursionChk,sg,mg,c,tp,min,max,minc,maxc,sg,matg,ct,matct,mustbemat,exchk,f,mustg,lv,eqmg,equips_inverse,gwg,gmg,Double)
						if #selg==0 then break end
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
						local cancelable=not og and Duel.IsSummonCancelable() and #sg==0
						local sc=Group.SelectUnselect(selg,sg,tp,finishable,cancelable)
						if not sc then
							if not finishable then return false end
							break
						end
						if not sg:IsContains(sc) then
							sg:AddCard(sc)
							if sc:IsHasEffect(EFFECT_ORICHALCUM_CHAIN) then
								extra_mats=extra_mats+1
							else
								matg:AddCard(sc)
								if equips_inverse and equips_inverse[sc] then
									mg:Merge(equips_inverse[sc])
								end
								local function chkset(db) return Xyz.CheckMaterialSet(matg,c,tp,exchk,mustg,lv,min,max,gmg,db) end
								local function checkother(n1,n2,db) return mg:IsExists(Xyz.RecursionChk,1,sg,mg,c,tp,min,max,minc,maxc,sg,matg,n1,n2,mustbemat,exchk,f,mustg,lv,eqmg,equips_inverse,gwg,gmg,db) end
								local gwp,gwf,gwv=gwg:IsContains(sc) and not mustbemat,false,0
								if gwp then
									gwv=sc:GetCardEffect(EFFECT_GALAXY_WIZARD):GetValue()
									gwp=maxc==infToken or matct+1+gwv<=maxc
									if gwp then gwf=not sc:IsXyzLevel(c,lv) end
								end
								local gmf,ignored=false,#(gmg&matg)>0
								local gmp=ignored and Double==0 and not (gwf or mustbemat) and (maxc==infToken or matct+2<=maxc)
								if gmp then
									if maxc~=infToken then
										gmf=matct+2==maxc
									else
										gmf=not mg:IsExists(Card.IsHasEffect,1,matg,EFFECT_GAGAGA_MIRAGE)
									end
								end
								local multiXyz={sc:IsHasEffect(EFFECT_DOUBLE_XYZ_MATERIAL,tp)}
								local multi,numTab={},{}
								local ctchk=ct<minc or ((gmp or not chkset(Double)) and sc:IsHasEffect(EFFECT_GAGAGA_MIRAGE))
								if not (gwf or gmf or mustbemat) and #multiXyz>0 and Xyz.CheckValidMultiXyzMaterial(multiXyz,c,matg) and ctchk then
									if checkother(ct+1,matct+1,Double) then multi[1]={} end
									for _,te in ipairs(multiXyz) do
										local tgf,val=te:GetOperation(),te:GetValue()
										if val>0 and (not tgf or tgf(te,c,matg)) then
											local newCount=matct+1+val
											te:UseCountLimit(tp)
											local double_plus=Double
											if sc:IsHasEffect(EFFECT_GAGAGA_MIRAGE) and val==1 then double_plus=double_plus+1 end
											local chk=(minc<=newCount and (not maxc or maxc==infToken or newCount<=maxc) and chkset(double_plus)) or checkother(ct+1,newCount,double_plus)
											if chk then
												if not multi[1+val] then multi[1+val]={} end
												table.insert(multi[1+val],te)
											end
											te:RestoreCountLimit(tp)
										end
									end
									for k in pairs(multi) do table.insert(numTab,k) end
								end
								if gwp and not (gwf or gmf) then
									local gwmatct=matct+1+gwv
									gwf=#numTab==0 and minc>=gwmatct and not checkother(ct+1,matct+1,Double) and (chkset(Double) or checkother(ct+1,gwmatct,Double))
									if not gwf and (maxc==infToken or gwmatct<=maxc) then
										if (minc<=gwmatct and chkset(Double)) or checkother(ct+1,gwmatct,Double) then
											gwf=Duel.SelectYesNo(tp,aux.Stringid(511600442,0))
										end
									end
								end
								local function GmEffOwners(_c)
									local effg=Group.CreateGroup()
									for _,ce in ipairs({_c:GetCardEffect(EFFECT_GAGAGA_MIRAGE)}) do effg:AddCard(ce:GetOwner()) end
									return effg
								end
								if gwf then
									extra_mats=extra_mats+gwv
									local flage=sc:RegisterFlagEffect(5160442,RESET_EVENT|RESETS_CANNOT_ACT,0,0)
									gwCards[sc]={gwv,flage}
								elseif gmf then
									extra_mats=extra_mats+1
									Double=Double+1
									gmCards[sc]=GmEffOwners(sc)
								else
									if #numTab>0 then
										local chosen=numTab[1]
										if #numTab~=1 then
											table.sort(numTab)
											Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
											chosen=Duel.AnnounceNumber(tp,numTab)
										end
										if chosen>1 then
											if chosen==2 and sc:IsHasEffect(EFFECT_GAGAGA_MIRAGE) and Double==0 then
												extra_mats=extra_mats+1
												Double=Double+1
												gmCards[sc]=GmEffOwners(sc)
											else
												extra_mats=extra_mats+chosen-1
												local eff=multi[chosen][1]
												eff:UseCountLimit(tp)
												multiXyzSelectedCards[sc]={eff,chosen}
											end
										end
									end
								end
							end
						else
							if equips_inverse and equips_inverse[sc] then
								local equips=equips_inverse[sc]
								if #(sg&equips)>0 then goto continue end
								mg:Sub(equips)
							end
							sg:RemoveCard(sc)
							if sc:IsHasEffect(EFFECT_ORICHALCUM_CHAIN) then
								extra_mats=extra_mats-1
							else
								matg:RemoveCard(sc)
								local multiXyzSelection,gwcheck,gmcheck=multiXyzSelectedCards[sc],gwCards[sc],gmCards[sc]
								if gwcheck then
									gwCards[sc]=nil
									local gwv,flage=gwcheck[1],gwcheck[2]
									extra_mats=extra_mats-gwv
									flage:Reset()
								elseif gmcheck then
									gmCards[sc]=nil
									extra_mats=extra_mats-1
									Double=Double-1
								elseif multiXyzSelection then
									local eff,num=table.unpack(multiXyzSelection)
									eff:RestoreCountLimit(tp)
									extra_mats=extra_mats-(num-1)
								end
							end
						end
						finishable=#matg+extra_mats>=minc and Xyz.CheckMaterialSet(matg,c,tp,exchk,mustg,lv,min,max,gmg,Double)
						::continue::
					end
					local _,req_ignored=Xyz.CheckMaterialSet(matg,c,tp,exchk,mustg,lv,min,max,gmg,Double,true)
					if #(gmg&matg)>0 or req_ignored then
						local _,effg=next(gmCards)
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
						local effc = #effg==1 and effg:GetFirst() or effg:Select(tp,1,1,nil):GetFirst()
						effc:RegisterFlagEffect(5160443,RESETS_STANDARD_PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(511600443,0))
						Duel.Hint(HINT_CARD,0,511600443)
					end
					e:SetLabelObject(sg)
					return true
				end
				return false
			end
end
function Xyz.Operation(f,lv,minc,maxc,mustbemat,exchk)
	return  function(e,tp,eg,ep,ev,re,r,rp,c,must,og,min,max)
				local g=e:GetLabelObject()
				if not g then return end
				local remg=g:Filter(Card.IsHasEffect,nil,EFFECT_ORICHALCUM_CHAIN)
				remg:ForEach(Card.RegisterFlagEffect,511002115,RESET_EVENT|RESETS_STANDARD,0,0)
				g:Remove(Card.IsHasEffect,nil,EFFECT_ORICHALCUM_CHAIN):Remove(Card.IsHasEffect,nil,511002115)
				c:SetMaterial(g)
				Duel.Overlay(c,g,true)
				Xyz.CheckAdditional=nil
				g:DeleteGroup()
			end
end

function Xyz.GetAlterMaterials(tp,xyz)
	return Duel.GetMatchingGroup(function(c)
		return c:IsFaceup() and (c:IsControler(tp) or Xyz.EffectXyzMaterialChk(c,xyz,tp))
	end,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
end
function Xyz.AlterFilter(c,alterf,xyz,e,tp,op)
	if not alterf(c,tp,xyz) or not c:IsCanBeXyzMaterial(xyz,tp) or (op and not op(e,tp,0,c)) then return false end
	if Xyz.CheckAdditional and not Xyz.CheckAdditional(Group.FromCards(c),xyz,tp) then return false end
	if xyz:IsLocation(LOCATION_EXTRA) then return Duel.GetLocationCountFromEx(tp,tp,c,xyz)>0 end
	return Duel.GetMZoneCount(tp,c,tp)>0
end
function Xyz.AlterFilter2(c,alterf,xyz,e,tp,op)
	return (c:IsControler(tp) or Xyz.EffectXyzMaterialChk(c,xyz,tp)) and Xyz.AlterFilter(c,alterf,xyz,e,tp,op)
end
--Xyz summon(alterf)
function Xyz.Condition2(alterf,op)
	return  function(e,c,must,og,min,max)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local g,mg
				if og then
					g=og
					mg=g:Filter(Xyz.AlterFilter2,nil,alterf,c,e,tp,op)
				else
					g=Xyz.GetAlterMaterials(tp,c)
					mg=g:Filter(Xyz.AlterFilter,nil,alterf,c,e,tp,op)
				end
				if #mg==0 then return false end
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_XYZ)
				if must then mustg:Merge(must) end
				return #mustg<=1 and (not min or min<=1) and mg:Includes(mustg)
			end
end
function Xyz.Target2(alterf,op)
	return  function(e,tp,eg,ep,ev,re,r,rp,chk,c,must,og,min,max)
				local cancelable=not og and Duel.IsSummonCancelable()
				Xyz.ProcCancellable=cancelable
				local g,mg
				if og then
					g=og
					mg=g:Filter(Xyz.AlterFilter2,nil,alterf,c,e,tp,op)
				else
					g=Xyz.GetAlterMaterials(tp,c)
					mg=g:Filter(Xyz.AlterFilter,nil,alterf,c,e,tp,op)
				end
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_XYZ)
				if must then mustg:Merge(must) end
				local oc
				if must and #must==min and #must==max then
					oc=mustg:GetFirst()
				elseif #mustg>0 then
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
					local ocg=mustg:Select(tp,1,1,cancelable,nil)
					if ocg then
						oc=ocg:GetFirst()
					end
				else
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
					local ocg=mg:FilterSelect(tp,Xyz.AlterFilter,1,1,cancelable,nil,alterf,c,e,tp,op)
					if ocg then
						oc=ocg:GetFirst()
					end
				end
				if not oc or (op and not op(e,tp,1,oc)) then return false end
				e:SetLabelObject(oc)
				return true
			end
end
function Xyz.Operation2(alterf,op)
	return  function(e,tp,eg,ep,ev,re,r,rp,c,must,og,min,max)
				local oc=e:GetLabelObject()
				c:SetMaterial(oc)
				Duel.Overlay(c,oc)
				Xyz.CheckAdditional=nil
			end
end
