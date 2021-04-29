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
		end
	end
)()


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
function Fusion.SummonEffFilter(c,fusfilter,e,tp,mg,gc,chkf,value,sumlimit,nosummoncheck,sumpos)
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
					local mg1=Duel.GetFusionMaterial(tp):Filter(matfilter,nil,e,tp,0)
					local checkAddition=nil
					if extrafil then
						local ret = {extrafil(e,tp,mg1)}
						if ret[1] then
							Fusion.ExtraGroup=ret[1]:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
							mg1:Merge(ret[1])
						end
						checkAddition=ret[2]
					end
					if gc and not mg1:Includes(gc) then
						Fusion.ExtraGroup=nil
						return false
					end
					Fusion.CheckAdditional=checkAddition
					mg1=mg1:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
					Fusion.CheckExact=exactcount
					Fusion.CheckMin=mincount
					Fusion.CheckMax=maxcount
					local res=Duel.IsExistingMatchingCard(Fusion.SummonEffFilter,tp,location,0,1,nil,fusfilter,e,tp,mg1,gc,chkf,value&0xffffffff,sumlimit,nosummoncheck,sumpos)
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
				local mg1=Duel.GetFusionMaterial(tp):Filter(matfilter,nil,e,tp,1)
				local extragroup=nil
				if extrafil then
					local ret = {extrafil(e,tp,mg1)}
					if ret[1] then
						Fusion.ExtraGroup=ret[1]:Filter(Card.IsCanBeFusionMaterial,nil,nil,value):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
						extragroup=ret[1]
						mg1:Merge(ret[1])
					end
					checkAddition=ret[2]
				end
				mg1=mg1:Filter(Card.IsCanBeFusionMaterial,nil,nil,value)
				mg1=mg1:Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
				if gc and (not mg1:Includes(gc) or gc:IsExists(Fusion.ForcedMatValidity,1,nil,e)) then
					Fusion.ExtraGroup=nil
					return false
				end
				Fusion.CheckExact=exactcount
				Fusion.CheckMin=mincount
				Fusion.CheckMax=maxcount
				Fusion.CheckAdditional=checkAddition
				local effswithgroup={}
				local sg1=Duel.GetMatchingGroup(Fusion.SummonEffFilter,tp,location,0,nil,fusfilter,e,tp,mg1,gc,chkf,value&0xffffffff,sumlimit,nosummoncheck,sumpos)
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
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local tc=sg:Select(tp,1,1,nil):GetFirst()
					if preselect and preselect(e,tc)==false then
						return
					end
					local sel=effswithgroup[Fusion.ChainMaterialPrompt(effswithgroup,tc:GetCardID(),tp,e)]
					local backupmat=nil
					if sel[1]==e then
						Fusion.CheckAdditional=checkAddition
						Fusion.ExtraGroup=extragroup
						local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,gc,chkf)
						Fusion.ExtraGroup=nil
						backupmat=mat1:Clone()
						tc:SetMaterial(mat1)
						if extraop then
							if extraop(e,tc,tp,mat1)==false then return end
						end
						if #mat1>0 then
							local ingrave,notgrave=mat1:Split(Card.IsLocation,nil,LOCATION_GRAVE)
							if #ingrave>0 then
								Duel.Remove(ingrave,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
							end
							if #notgrave>0 then
								Duel.SendtoGrave(notgrave,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
							end
						end
						Duel.BreakEffect()
						Duel.SpecialSummonStep(tc,value,tp,tp,sumlimit,false,sumpos)
					else
						local ce=sel[1]
						local fcheck=nil
						if ce:GetLabelObject() then fcheck=ce:GetLabelObject():GetOperation() end
						Fusion.CheckAdditional=checkAddition
						if fcheck then
							if checkAddition then Fusion.CheckAdditional=aux.AND(checkAddition,fcheck) else Fusion.CheckAdditional=fcheck end
						end
						Fusion.ExtraGroup=ce:GetTarget()(ce,e,tp,value)
						local mat2=Duel.SelectFusionMaterial(tp,tc,Fusion.ExtraGroup,gc,chkf)
						Fusion.CheckAdditional=nil
						Fusion.ExtraGroup=nil
						ce:GetOperation()(sel[1],e,tp,tc,mat2,value,nil,sumpos)
						backupmat=tc:GetMaterial():Clone()
					end
					stage2(e,tc,tp,backupmat,0)
					Duel.SpecialSummonComplete()
					stage2(e,tc,tp,backupmat,3)
					if not sumlimit then
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
	Duel.SendtoDeck(sg,nil,2,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
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
