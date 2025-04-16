--The function generates a default Fusion Summon effect. By default it's usable for Spells/Traps, usage in monsters requires changing type and code afterwards.
--c				card that uses the effect
--fusfilter		filter for the monster to be Fusion Summoned
--matfilter		restriction on the default materials returned by GetFusionMaterial
--extrafil		function that returns a group of extra cards that can be used as fusion materials, and as second optional parameter the additional filter function
--extraop		function called right before sending the monsters to the graveyard as material
--gc			mandatory card or function returning a group to be used (for effects like Soprano)
--stage2		function called after the monster has been summoned
--exactcount
--location		location where to summon fusion monsters from (default LOCATION_EXTRA)
--chkf			FUSPROC flags for the fusion summon
--desc			summon effect description


Fusion.ExtraGroup=nil
local geff=Effect.GlobalEffect()
geff:SetType(EFFECT_TYPE_FIELD)
geff:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
geff:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
geff:SetTargetRange(0xff,0xff)
geff:SetTarget(function(e,c)
	return Fusion.ExtraGroup and Fusion.ExtraGroup:IsContains(c)
end)
geff:SetValue(aux.TRUE)
Duel.RegisterEffect(geff,0)

Debug.ReloadFieldBegin=(function()
	local old=Debug.ReloadFieldBegin
	return function(...)
			old(...)
			geff=Effect.GlobalEffect()
			geff:SetType(EFFECT_TYPE_FIELD)
			geff:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
			geff:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			geff:SetTargetRange(0xff,0xff)
			geff:SetTarget(function(e,c)
				return Fusion.ExtraGroup and Fusion.ExtraGroup:IsContains(c)
			end)
			geff:SetValue(aux.TRUE)
			Duel.RegisterEffect(geff,0)
		end
	end
)()

Duel.GetFusionMaterial=(function()
	local oldfunc=Duel.GetFusionMaterial
	return function(tp)
		local res=oldfunc(tp)
		local g=Duel.GetMatchingGroup(Card.IsHasEffect,tp,LOCATION_EXTRA,0,nil,EFFECT_EXTRA_FUSION_MATERIAL)
		if #g>0 then
			res:Merge(g)
		end
		return res
	end
end)()

--Returns the first EFFECT_EXTRA_FUSION_MATERIAL applied on Card c.
--If summon_card is provided, it will also check if the effect's value function applies to that card.
--Card.IsHasEffect alone cannot be used because it would return the above effect as well.
local function GetExtraMatEff(c,summon_card)
	local effs={c:IsHasEffect(EFFECT_EXTRA_FUSION_MATERIAL)}
	for _,eff in ipairs(effs) do
		if eff~=geff then
			if not summon_card then
				return eff
			end
			local val=eff:GetValue()
			if (type(val)=="function" and val(eff,summon_card)) or val==1 then
				return eff
			end
		end
	end
end
--Once per turn check for EFFECT_EXTRA_FUSION_MATERIAL effects.
--Removes cards from the material pool group if the OPT of the
--EFFECT_EXTRA_FUSION_MATERIAL effect has already been used.
--Returns the main material group and the extra material group separately, both
--of which are then passed to Fusion.SummonEffFilter.
local function ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
	local extra_feff_mg=mg1:Filter(GetExtraMatEff,nil)
	if #extra_feff_mg>0 then
		local extra_feff=GetExtraMatEff(extra_feff_mg:GetFirst())
		--Check if you need to remove materials from the pool if count limit has been used
		if extra_feff and not extra_feff:CheckCountLimit(tp) then
			--If "extrafil" exists and it doesn't return anything in
			--the GY (so that effects like "Dragon's Mirror" are excluded),
			--remove all the EFFECT_EXTRA_FUSION_MATERIAL cards
			--that are in the GY from the material group.
			--Hardcoded to LOCATION_GRAVE since it's currently
			--impossible to get the TargetRange of the
			--EFFECT_EXTRA_FUSION_MATERIAL effect (but the only OPT effect atm uses the GY).
			local extra_feff_loc=extra_feff:GetTargetRange()
			if extrafil then
				local extrafil_g=extrafil(e,tp,mg1)
				if extrafil_g and #extrafil_g>0 and not extrafil_g:IsExists(Card.IsLocation,1,nil,extra_feff_loc) then
					mg1:Sub(extra_feff_mg:Filter(Card.IsLocation,nil,extra_feff_loc))
					efmg:Clear()
				elseif not extrafil_g then
					mg1:Sub(extra_feff_mg:Filter(Card.IsLocation,nil,extra_feff_loc))
					efmg:Clear()
				end
			--If "extrafil" doesn't exist then remove all the
			--EFFECT_EXTRA_FUSION_MATERIAL cards from the material group.
			--A more complete implementation would check for cases where the
			--Fusion Summoning effect can use the whole field (including LOCATION_SZONE),
			--but it's currently not possible to know if that is the case
			--(only relevant for "Fullmetalfoes Alkahest" atm, but he's not OPT).
			else
				mg1:Sub(extra_feff_mg:Filter(Card.IsLocation,nil,extra_feff_loc))
				efmg:Clear()
			end
		end
	elseif #efmg>0 then
		local extra_feff=GetExtraMatEff(efmg:GetFirst())
		if extra_feff and not extra_feff:CheckCountLimit(tp) then
			efmg:Clear()
		end
	end
	return mg1,efmg
end

Fusion.CreateSummonEff = aux.FunctionWithNamedArgs(
function(c,fusfilter,matfilter,extrafil,extraop,gc,stage2,exactcount,value,location,chkf,desc,preselect,nosummoncheck,extratg,mincount,maxcount,sumpos)
	local e1=Effect.CreateEffect(c)
	if desc then
		e1:SetDescription(desc)
	else
		e1:SetDescription(1170)
	end
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(Fusion.SummonEffTG(fusfilter,matfilter,extrafil,extraop,gc,stage2,exactcount,value,location,chkf,preselect,nosummoncheck,extratg,mincount,maxcount,sumpos))
	e1:SetOperation(Fusion.SummonEffOP(fusfilter,matfilter,extrafil,extraop,gc,stage2,exactcount,value,location,chkf,preselect,nosummoncheck,mincount,maxcount,sumpos))
	return e1
end,"handler","fusfilter","matfilter","extrafil","extraop","gc","stage2","exactcount","value","location","chkf","desc","preselect","nosummoncheck","extratg","mincount","maxcount","sumpos")
function Fusion.RegisterSummonEff(c,...)
	local tab=type(c)=="table"
	local e1=Fusion.CreateSummonEff(tab and c or c,...)
	Card.RegisterEffect((tab and c["handler"] or c),e1)
	return e1
end
function Fusion.SummonEffFilter(c,fusfilter,e,tp,mg,gc,chkf,value,sumlimit,nosummoncheck,sumpos,efmg)
	--efmg is the group of Fusion Materials with an EFFECT_EXTRA_FUSION_MATERIAL effect.
	--If any materials in that group with that effect are valid materials for Card c
	--then merge those into mg before performing the check below.
	--Attempt to fix the interaction between an EFFECT_EXTRA_FUSION_MATERIAL effect
	--and Fusion Summoning effects that normally allow you to only use a single location
	--(e.g. with "Flash Fusion" you can normally only use monsters on your field).
	if efmg then
		mg:Merge(efmg:Filter(GetExtraMatEff,nil,c))
	end
	return c:IsType(TYPE_FUSION) and (not fusfilter or fusfilter(c,tp)) and (nosummoncheck or c:IsCanBeSpecialSummoned(e,value,tp,sumlimit,false,sumpos))
			and c:CheckFusionMaterial(mg,gc,chkf)
end

function Fusion.ForcedMatValidity(c,e)
	if c==e:GetHandler() then
		return not c:IsRelateToEffect(e)
	end
	return c:IsImmuneToEffect(e)
end

Fusion.SummonEffTG = aux.FunctionWithNamedArgs(
function(fusfilter,matfilter,extrafil,extraop,gc2,stage2,exactcount,value,location,chkf,preselect,nosummoncheck,extratg,mincount,maxcount,sumpos)
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				location=location or LOCATION_EXTRA
				if not chkf or ((chkf&PLAYER_NONE)~=PLAYER_NONE) then
					chkf=chkf and chkf|tp or tp
				end
				local sumlimit=(chkf&(FUSPROC_NOTFUSION|FUSPROC_NOLIMIT))~=0
				local notfusion=(chkf&FUSPROC_NOTFUSION)~=0
				if not value then value=0 end
				value = value|MATERIAL_FUSION
				if not notfusion then
					value = value|SUMMON_TYPE_FUSION
				end
				local gc=gc2
				gc=type(gc)=="function" and gc(e,tp,eg,ep,ev,re,r,rp,chk) or gc
				gc=type(gc)=="Card" and Group.FromCards(gc) or gc
				matfilter=matfilter or Card.IsAbleToGrave
				stage2 = stage2 or aux.TRUE
				if chk==0 then
					--Separate the Fusion Materials filtered by matfilter
					--and the ones with an EFFECT_EXTRA_FUSION_MATERIAL effect.
					--Both will be passed to Fusion.SummonEffFilter later.
					local fmg_all=Duel.GetFusionMaterial(tp)
					local mg1=fmg_all:Filter(matfilter,nil,e,tp,0)
					local efmg=fmg_all:Filter(GetExtraMatEff,nil)
					local checkAddition=nil
					local repl_flag=false
					if #efmg>0 then
						local extra_feff=GetExtraMatEff(efmg:GetFirst())
						if extra_feff and extra_feff:GetLabelObject() then
							local repl_function=extra_feff:GetLabelObject()
							repl_flag=true
							-- no extrafil (Poly):
							if not extrafil then
								local ret = {repl_function[1](e,tp,mg1)}
								if ret[1] then
									ret[1]:Match(matfilter,nil,e,tp,0)
									if repl_function[2] then
										ret[1]:Match(repl_function[2],nil,e,tp)
										efmg:Match(repl_function[2],nil,e,tp)
									end
									Fusion.ExtraGroup=ret[1]:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
									mg1:Merge(ret[1])
								end
								checkAddition=ret[2]
							-- extrafil but no fcheck (Shaddoll Fusion):
							elseif extrafil then
								local ret = {extrafil(e,tp,mg1)}
								local repl={repl_function[1](e,tp,mg1)}
								if ret[1] then
									repl[1]:Match(matfilter,nil,e,tp,0)
									ret[1]:Merge(repl[1])
									Fusion.ExtraGroup=ret[1]:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
									mg1:Merge(ret[1])
								end
								if ret[2] then
									-- extrafil and fcheck (Cynet Fusion):
									checkAddition=aux.AND(ret[2],repl[2])
								else
									checkAddition=repl[2]
								end
							end
						end
					end
					if not repl_flag and extrafil then
						local ret = {extrafil(e,tp,mg1)}
						if ret[1] then
							Fusion.ExtraGroup=ret[1]:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
							mg1:Merge(ret[1])
						end
						checkAddition=ret[2]
					end
					if gc and not mg1:Includes(gc) then
						Fusion.ExtraGroup=nil
						return false
					end
					Fusion.CheckAdditional=checkAddition
					mg1:Match(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
					Fusion.CheckExact=exactcount
					Fusion.CheckMin=mincount
					Fusion.CheckMax=maxcount
					--Adjust the main material group and the extra material group accordingly
					--if an OPT EFFECT_EXTRA_FUSION_MATERIAL effect has already been used.
					--Both will be passed to Fusion.SummonEffFilter later.
					mg1,efmg=ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
					local res=Duel.IsExistingMatchingCard(Fusion.SummonEffFilter,tp,location,0,1,nil,fusfilter,e,tp,mg1,gc,chkf,value&0xffffffff,sumlimit,nosummoncheck,sumpos,efmg)
					Fusion.CheckAdditional=nil
					Fusion.ExtraGroup=nil
					if not res and not notfusion then
						for _,ce in ipairs({Duel.GetPlayerEffect(tp,EFFECT_CHAIN_MATERIAL)}) do
							local fgroup=ce:GetTarget()
							local mg=fgroup(ce,e,tp,value)
							if #mg>0 and (not Fusion.CheckExact or #mg==Fusion.CheckExact) and (not Fusion.CheckMin or #mg>=Fusion.CheckMin) then
								local mf=ce:GetValue()
								local fcheck=nil
								if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
								Fusion.CheckAdditional=checkAddition
								if fcheck then
									if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,fcheck) else Fusion.CheckAdditional=fcheck end
								end
								Fusion.ExtraGroup=mg
								if Duel.IsExistingMatchingCard(Fusion.SummonEffFilter,tp,location,0,1,nil,aux.AND(mf,fusfilter or aux.TRUE),e,tp,mg,gc,chkf,value,sumlimit,nosummoncheck,sumpos) then
									res=true
									Fusion.CheckAdditional=nil
									Fusion.ExtraGroup=nil
									break
								end
								Fusion.CheckAdditional=nil
								Fusion.ExtraGroup=nil
							end
						end
					end
					Fusion.CheckExact=nil
					Fusion.CheckMin=nil
					Fusion.CheckMax=nil
					return res
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,location)
				if extratg then extratg(e,tp,eg,ep,ev,re,r,rp,chk) end
			end
end,"fusfilter","matfilter","extrafil","extraop","gc","stage2","exactcount","value","location","chkf","preselect","nosummoncheck","extratg","mincount","maxcount","sumpos")
function aux.GrouptoCardid(g)
	local res={}
	for card in aux.Next(g) do
		res[card:GetCardID()] = true
	end
	return res
end
function Fusion.ChainMaterialPrompt(effswithgroup,cardID,tp,e)
	local effs = {}
	for i,eff in ipairs(effswithgroup) do
		if eff[2][cardID] ~= nil then
			table.insert(effs,i)
		end
	end
	if #effs == 1 then return effs[1] end
	local desctable = {}
	for _,index in ipairs(effs) do
		table.insert(desctable,effswithgroup[index][1]:GetDescription())
	end
	return effs[Duel.SelectOption(tp,false,table.unpack(desctable)) + 1]
end
Fusion.SummonEffOP = aux.FunctionWithNamedArgs(
function (fusfilter,matfilter,extrafil,extraop,gc2,stage2,exactcount,value,location,chkf,preselect,nosummoncheck,mincount,maxcount,sumpos)
	sumpos = sumpos or POS_FACEUP
	return	function(e,tp,eg,ep,ev,re,r,rp)
				location=location or LOCATION_EXTRA
				chkf = chkf and chkf|tp or tp
				if not preselect then chkf=chkf|FUSPROC_CANCELABLE end
				local sumlimit=(chkf&(FUSPROC_NOTFUSION|FUSPROC_NOLIMIT))~=0
				local notfusion=(chkf&FUSPROC_NOTFUSION)~=0
				if not value then value=0 end
				if not notfusion then
					value = value|SUMMON_TYPE_FUSION|MATERIAL_FUSION
				end
				local gc=gc2
				gc=type(gc)=="function" and gc(e,tp,eg,ep,ev,re,r,rp,chk) or gc
				gc=type(gc)=="Card" and Group.FromCards(gc) or gc
				matfilter=matfilter or Card.IsAbleToGrave
				stage2 = stage2 or aux.TRUE
				local checkAddition
				--Same as line 167 above
				local fmg_all=Duel.GetFusionMaterial(tp)
				local mg1=fmg_all:Filter(matfilter,nil,e,tp,1)
				local efmg=fmg_all:Filter(GetExtraMatEff,nil)
				local extragroup=nil
				local repl_flag=false
				if #efmg>0 then
					local extra_feff=GetExtraMatEff(efmg:GetFirst())
					if extra_feff and extra_feff:GetLabelObject() then
						local repl_function=extra_feff:GetLabelObject()
						repl_flag=true
						-- no extrafil (Poly):
						if not extrafil then
							local ret = {repl_function[1](e,tp,mg1)}
							if ret[1] then
								ret[1]:Match(matfilter,nil,e,tp,1)
								if repl_function[2] then
									ret[1]:Match(repl_function[2],nil,e,tp)
									efmg:Match(repl_function[2],nil,e,tp)
								end
								Fusion.ExtraGroup=ret[1]:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
								mg1:Merge(ret[1])
							end
							checkAddition=ret[2]
						-- extrafil but no fcheck (Shaddoll Fusion):
						elseif extrafil then
							local ret = {extrafil(e,tp,mg1)}
							local repl={repl_function[1](e,tp,mg1)}
							if ret[1] then
								repl[1]:Match(matfilter,nil,e,tp,1)
								ret[1]:Merge(repl[1])
								Fusion.ExtraGroup=ret[1]:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
								mg1:Merge(ret[1])
							end
							if ret[2] then
								-- extrafil and fcheck (Cynet Fusion):
								checkAddition=aux.AND(ret[2],repl[2])
							else
								checkAddition=repl[2]
							end
						end
					end
				end
				if not repl_flag and extrafil then
					local ret = {extrafil(e,tp,mg1)}
					if ret[1] then
						Fusion.ExtraGroup=ret[1]:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
						extragroup=ret[1]
						mg1:Merge(ret[1])
					end
					checkAddition=ret[2]
				end
				mg1:Match(Card.IsCanBeFusionMaterial,nil,nil,value):Match(aux.NOT(Card.IsImmuneToEffect),nil,e)
				if gc and (not mg1:Includes(gc) or gc:IsExists(Fusion.ForcedMatValidity,1,nil,e)) then
					Fusion.ExtraGroup=nil
					return false
				end
				Fusion.CheckExact=exactcount
				Fusion.CheckMin=mincount
				Fusion.CheckMax=maxcount
				Fusion.CheckAdditional=checkAddition
				local effswithgroup={}
				--Same as line 191 above
				mg1,efmg=ExtraMatOPTCheck(mg1,e,tp,extrafil,efmg)
				local sg1=Duel.GetMatchingGroup(Fusion.SummonEffFilter,tp,location,0,nil,fusfilter,e,tp,mg1,gc,chkf,value&0xffffffff,sumlimit,nosummoncheck,sumpos,efmg)
				if #sg1>0 then
					table.insert(effswithgroup,{e,aux.GrouptoCardid(sg1)})
				end
				Fusion.ExtraGroup=nil
				Fusion.CheckAdditional=nil
				if not notfusion then
					local extraeffs = {Duel.GetPlayerEffect(tp,EFFECT_CHAIN_MATERIAL)}
					for _,ce in ipairs(extraeffs) do
						local fgroup=ce:GetTarget()
						local mg2=fgroup(ce,e,tp,value)
						if #mg2>0 and (not Fusion.CheckExact or #mg2==Fusion.CheckExact) and (not Fusion.CheckMin or #mg2>=Fusion.CheckMin) then
							local mf=ce:GetValue()
							local fcheck=nil
							if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
							Fusion.CheckAdditional=checkAddition
							if fcheck then
								if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,fcheck) else Fusion.CheckAdditional=fcheck end
							end
							Fusion.ExtraGroup=mg2
							local sg2=Duel.GetMatchingGroup(Fusion.SummonEffFilter,tp,location,0,nil,aux.AND(mf,fusfilter or aux.TRUE),e,tp,mg2,gc,chkf,value,sumlimit,nosummoncheck,sumpos)
							if #sg2 > 0 then
								table.insert(effswithgroup,{ce,aux.GrouptoCardid(sg2)})
								sg1:Merge(sg2)
							end
							Fusion.CheckAdditional=nil
							Fusion.ExtraGroup=nil
						end
					end
				end
				if #sg1>0 then
					local sg=sg1:Clone()
					local mat1=Group.CreateGroup()
					local sel=nil
					local backupmat=nil
					local tc=nil
					local ce=nil
					while #mat1==0 do
						Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
						tc=sg:Select(tp,1,1,nil):GetFirst()
						if preselect and preselect(e,tc)==false then
							return
						end
						sel=effswithgroup[Fusion.ChainMaterialPrompt(effswithgroup,tc:GetCardID(),tp,e)]
						if sel[1]==e then
							Fusion.CheckAdditional=checkAddition
							Fusion.ExtraGroup=extragroup
							mat1=Duel.SelectFusionMaterial(tp,tc,mg1,gc,chkf)
						else
							ce=sel[1]
							local fcheck=nil
							if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
							Fusion.CheckAdditional=checkAddition
							if fcheck then
								if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,fcheck) else Fusion.CheckAdditional=fcheck end
							end
							Fusion.ExtraGroup=ce:GetTarget()(ce,e,tp,value)
							mat1=Duel.SelectFusionMaterial(tp,tc,Fusion.ExtraGroup,gc,chkf)
						end
					end
					if sel[1]==e then
						Fusion.ExtraGroup=nil
						backupmat=mat1:Clone()
						if not notfusion then
							tc:SetMaterial(mat1)
						end
						--Checks for the case that the Fusion Summoning effect has an "extraop"
						local extra_feff_mg=mat1:Filter(GetExtraMatEff,nil,tc)
						if #extra_feff_mg>0 and extraop then
							local extra_feff=GetExtraMatEff(extra_feff_mg:GetFirst(),tc)
							if extra_feff then
								local extra_feff_op=extra_feff:GetOperation()
								--If the operation of the EFFECT_EXTRA_FUSION_MATERIAL effect is different than "extraop",
								--it's not OPT or it hasn't been used yet, and the player
								--chooses to apply the effect, then select which cards
								--the effect will be applied to and execute its operation.
								if extra_feff_op and extraop~=extra_feff_op and extra_feff:CheckCountLimit(tp) then
									local flag=nil
									if extrafil then
										local extrafil_g=extrafil(e,tp,mg1)
										if #extrafil_g>=0 and not extrafil_g:IsExists(Card.IsLocation,1,nil,extra_feff:GetTargetRange()) then
											--The Fusion effect by default does not use the GY
											--so the player is forced to apply this effect.
											mat1:Sub(extra_feff_mg)
											extra_feff_op(e,tc,tp,extra_feff_mg)
											flag=true
										elseif #extrafil_g>=0 and Duel.SelectEffectYesNo(tp,extra_feff:GetHandler()) then
											--Select which cards you'll apply the
											--EFFECT_EXTRA_FUSION_MATERIAL effect to
											--and execute its operation.
											Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RESOLVECARD)
											local g=extra_feff_mg:Select(tp,1,#extra_feff_mg,nil)
											if #g>0 then
												mat1:Sub(g)
												extra_feff_op(e,tc,tp,g)
												flag=true
											end
										end
									else
										--The Fusion effect by default does not use the GY
										--so the player is forced to apply this effect.
										mat1:Sub(extra_feff_mg)
										extra_feff_op(e,tc,tp,extra_feff_mg)
										flag=true
									end
									--If the EFFECT_EXTRA_FUSION_MATERIAL effect is OPT
									--then "use" its count limit.
									if flag and extra_feff:CheckCountLimit(tp) then
										extra_feff:UseCountLimit(tp,1)
									end
								end
							end
						end
						if extraop then
							if extraop(e,tc,tp,mat1)==false then return end
						end
						if #mat1>0 then
							--Split the group of selected materials to
							--"extra_feff_mg" and "normal_mg", send "normal_mg"
							--to the GY, and execute the operation of the
							--EFFECT_EXTRA_FUSION_MATERIAL effect, if it exists.
							--If it doesn't exist then send the extra materials to the GY.
							local extra_feff_mg,normal_mg=mat1:Split(GetExtraMatEff,nil,tc)
							local extra_feff
							if #extra_feff_mg>0 then extra_feff=GetExtraMatEff(extra_feff_mg:GetFirst(),tc) end
							if #normal_mg>0 and (not extra_feff or extra_feff:GetLabel()~=160018042) then
								normal_mg=normal_mg:AddMaximumCheck()
								Duel.SendtoGrave(normal_mg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
							end
							if extra_feff then
								local extra_feff_op=extra_feff:GetOperation()
								if extra_feff_op then
									extra_feff_op(e,tc,tp,extra_feff_mg)
								else
									extra_feff_mg=extra_feff_mg:AddMaximumCheck()
									Duel.SendtoGrave(extra_feff_mg,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
								end
								--If the EFFECT_EXTRA_FUSION_MATERIAL effect is OPT
								--then "use" its count limit.
								if extra_feff:CheckCountLimit(tp) then
									extra_feff:UseCountLimit(tp,1)
								end
							end
						end
						Duel.BreakEffect()
						Duel.SpecialSummonStep(tc,value,tp,tp,sumlimit,false,sumpos)
					else
						Fusion.CheckAdditional=nil
						Fusion.ExtraGroup=nil
						ce:GetOperation()(sel[1],e,tp,tc,mat1,value,nil,sumpos)
						backupmat=tc:GetMaterial():Clone()
					end
					stage2(e,tc,tp,backupmat,0)
					Duel.SpecialSummonComplete()
					stage2(e,tc,tp,backupmat,3)
					if (chkf&FUSPROC_NOTFUSION)==0 then
						tc:CompleteProcedure()
					end
					stage2(e,tc,tp,backupmat,1)
				end
				stage2(e,nil,tp,nil,2)
				Fusion.CheckMin=nil
				Fusion.CheckMax=nil
				Fusion.CheckExact=nil
				Fusion.CheckAdditional=nil
			end
end,"fusfilter","matfilter","extrafil","extraop","gc","stage2","exactcount","value","location","chkf","preselect","nosummoncheck","mincount","maxcount","sumpos")
function Fusion.BanishMaterial(e,tc,tp,sg)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
	sg:Clear()
end
function Fusion.ShuffleMaterial(e,tc,tp,sg)
	local rg=sg:Filter(Card.IsFacedown,nil)
	local hg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE|LOCATION_REMOVED)
	if #rg>0 then Duel.ConfirmCards(1-tp,rg) end
	if #hg>0 then Duel.HintSelection(hg,true) end
	local tg=sg:AddMaximumCheck()
	Duel.SendtoDeck(tg,nil,2,REASON_EFFECT|REASON_MATERIAL|REASON_FUSION)
	sg:Clear()
end
function Fusion.OnFieldMat(filter,...)
	if type(filter) == "Card" then
		--filter is actually the card parameter
		return filter:IsOnField() and filter:IsAbleToGrave()
	end
	local funs={filter,...}
	return function (c,...)
		local res = c:IsOnField()
		if res then
			for i,fil in ipairs(funs) do
				if not fil(c,...) then
					return false
				end
			end
		end
		return res
	end
end
function Fusion.InHandMat(filter,...)
	if type(filter) == "Card" then
		--filter is actually the card parameter
		return filter:IsLocation(LOCATION_HAND) and filter:IsAbleToGrave()
	end
	local funs={filter,...}
	return function (c,...)
		local res = c:IsLocation(LOCATION_HAND)
		if res then
			for i,fil in ipairs(funs) do
				if not fil(c,...) then
					return false
				end
			end
		end
		return res
	end
end
function Fusion.IsMonsterFilter(f1,...)
	local funs={f1,...}
	return	function(c,...)
		local res = c:IsMonster()
		if res then
			for i,fil in ipairs(funs) do
				if not fil(c,...) then
					return false
				end
			end
		end
		return res
	end
end
function Fusion.ForcedHandler(e)
	return e:GetHandler()
end
function Fusion.CheckWithHandler(fun,...)
	local funs={fun,...}
	return function(c,e,...)
		if c==e:GetHandler() then
			return true
		end
		for i,fil in ipairs(funs) do
			if fil(c,e,...) then
				return true
			end
		end
		return false
	end
end
