--The function generates a default Fusion Summon effect. By default it's usable for Spells/Traps, usage in monsters requires changing type and code afterwards.
--c				card that uses the effect
--fusfilter		filter for the monster to be Fusion Summoned
--matfilter		restriction on the default materials returned by GetFusionMaterial
--desc			summon effect description
--extrafil		function that returns a group of extra cards that can be used as fusion materials
--extraop		function called right before sending the monsters to the graveyard as material
--gc			mandatory card or function returning a group to be used (for effects like Soprano)
--stage2		function called after the monster has been summoned
--location		location where to summon fusion monsters from (default LOCATION_EXTRA)
--chkf			FUSPROC flags for the fusion summon

function Fusion.AddSummonEff(c,fusfilter,matfilter,desc,extrafil,extraop,gc,stage2,location,chkf)
	local e1=Effect.CreateEffect(c)
	if desc then
		e1:SetDescription(desc)
	end
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(Fusion.SummonEffTG(fusfilter,matfilter,extrafil,extraop,gc,stage2,location,chkf))
	e1:SetOperation(Fusion.SummonEffOP(fusfilter,matfilter,extrafil,extraop,gc,stage2,location,chkf))
	c:RegisterEffect(e1)
	return e1
end
function Fusion.SummonEffFilter(c,fusfilter,e,tp,mg,gc,chkf)
	return c:IsType(TYPE_FUSION) and (not fusfilter or fusfilter(c)) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)
			and c:CheckFusionMaterial(mg,gc,chkf)
end
function Fusion.SummonEffTG(fusfilter,matfilter,extrafil,extraop,gc,stage2,location,chkf)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				location = location or LOCATION_EXTRA
				chkf = chkf and chkf|tp or tp
				if chk==0 then
					local mg1=Duel.GetFusionMaterial(tp)
					if extrafil then
						mg1:Merge(extrafil(e,tp,eg,ep,ev,re,r,rp,chk):Filter(Card.IsCanBeFusionMaterial,nil))
					end
					if matfilter then
						mg1:Filter(matfilter,nil,e,tp,eg,ep,ev,re,r,rp)
					end
					local res=Duel.IsExistingMatchingCard(Fusion.SummonEffFilter,tp,location,0,1,nil,fusfilter,e,tp,mg1,type(gc)=="function" and gc(e,tp,eg,ep,ev,re,r,rp,chk) or gc,chk)
					if not res then
						for _,ce in ipairs({Duel.GetPlayerEffect(tp,EFFECT_CHAIN_MATERIAL)}) do
							local fgroup=ce:GetTarget()
							local mg=fgroup(ce,e,tp)
							local mf=ce:GetValue()
							if Duel.IsExistingMatchingCard(Fusion.SummonEffFilter,tp,location,0,1,nil,aux.AND(mf,fusfilter or aux.TRUE),e,tp,mg,type(gc)=="function" and gc(e,tp,eg,ep,ev,re,r,rp,chk) or gc,chkf) then
								return true
							end
						end		
					end
					return res
				end
				Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,location)
			end
end
function aux.GrouptoFieldid(g)
	local res={}
	for card in aux.Next(g) do
		res[card:GetRealFieldID()] = true
	end
	return res
end
function Fusion.ChainMaterialPrompt(effswithgroup,fieldID,tp,e)
	local effs = {}
	for i,eff in ipairs(effswithgroup) do
		if eff[2][fieldID] ~= nil then
			table.insert(effs,i)
		end
	end
	if #effs == 1 then return effs[1] end
	local desctable = {}
	for _,index in ipairs(effs) do
		if index == 1 then
			table.insert(desctable,e:GetDescription())
		else
			table.insert(desctable,effswithgroup[index][1]:GetDescription())
		end
	end
	return effs[Duel.SelectOption(tp,table.unpack(desctable)) + 1]
end
function Fusion.SummonEffOP(fusfilter,matfilter,extrafil,extraop,gc,stage2,location,chkf)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				location = location or LOCATION_EXTRA
				chkf = chkf and chkf|tp or tp
				local mg1=Duel.GetFusionMaterial(tp)
				if extrafil then
					mg1:Merge(extrafil(e,tp,eg,ep,ev,re,r,rp,chk):Filter(Card.IsCanBeFusionMaterial,nil))
				end
				if matfilter then
					mg1:Filter(matfilter,nil,e,tp,eg,ep,ev,re,r,rp)
				end
				mg1:Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
				local effswithgroup={}
				local sg1=Duel.GetMatchingGroup(Fusion.SummonEffFilter,tp,LOCATION_EXTRA,0,nil,ffilter,e,tp,mg,type(gc)=="function" and gc(e,tp,eg,ep,ev,re,r,rp,chk) or gc,chkf)
				local extraeffs = {Duel.GetPlayerEffect(tp,EFFECT_CHAIN_MATERIAL)}
				if #sg1 > 0 then
					table.insert(effswithgroup,{e,aux.GrouptoFieldid(sg1)})
				end
				for _,ce in ipairs(extraeffs) do
					local fgroup=ce:GetTarget()
					local mg2=fgroup(ce,e,tp)
					local mf=ce:GetValue()
					local sg2=Duel.GetMatchingGroup(Fusion.SummonEffFilter,tp,location,0,nil,aux.AND(mf,fusfilter or aux.TRUE),e,tp,mg,type(gc)=="function" and gc(e,tp,eg,ep,ev,re,r,rp,chk) or gc,chkf)
					if #sg2 > 0 then
						table.insert(effswithgroup,{ce,aux.GrouptoFieldid(sg2)})
						sg1:Merge(sg2)
					end
				end
				if #sg1>0 then
					local sg=sg1:Clone()
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
					local tc=sg:Select(tp,1,1,nil):GetFirst()
					local sel=effswithgroup[Fusion.ChainMaterialPrompt(effswithgroup,tc:GetRealFieldID(),tp,e)]
					local backupmat=nil
					if sel[1]==e then
						local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,gc,chkf)
						backupmat=mat1:Clone()
						tc:SetMaterial(mat1)
						if extraop then
							extraop(mat1,e,tp)
						end
						if #mat1>0 then
							Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
						end
						Duel.BreakEffect()
						Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
					else
						local mat2=Duel.SelectFusionMaterial(tp,tc,sel[1]:GetTarget()(ce,e,tp),gc,chkf)
						sel[1]:GetOperation()(sel[1],e,tp,tc,mat2)
					end
					tc:CompleteProcedure()
					stage2(backupmat,e,tp)
				end
			end
end