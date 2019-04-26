--Chitterite Bombardment Plan
function c210300210.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c210300210.rittg)
	e1:SetOperation(c210300210.ritop)
	c:RegisterEffect(e1)
	--Untargetable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--dir atk
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e3)
	--
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(function(e,tp,eg,ep,ev,re,r,rp,chk)
		local c=e:GetHandler()
		if chk==0 then return c:IsAbleToRemoveAsCost() and Duel.GetFlagEffect(tp,210300210)==0 end
		Duel.Remove(c,POS_FACEUP,REASON_COST)
		Duel.RegisterFlagEffect(tp,210300210+1000000,RESET_PHASE+PHASE_END,0,1)
	end)
	e3:SetOperation(c210300210.indop)
	c:RegisterEffect(e3)
end
c210300210.fit_monster={210300207}
function c210300210.rittg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp)
		local mg2=Duel.GetFieldGroup(tp,0,LOCATION_MZONE):Filter(Card.IsFaceup,nil):Filter(Card.IsCanBeRitualMaterial,tc,tc)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		return ft>-1 and Duel.GetFlagEffect(tp,210300210+1000000)==0
			and Duel.IsExistingMatchingCard(c210300210.RPGFilter,tp,LOCATION_HAND,0,1,nil,aux.FilterBoolFunction(Card.IsSetCard,0xf37),e,tp,mg,mg2,ft)
	end
	Duel.RegisterFlagEffect(tp,210300210,RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function c210300210.RPGFilter(c,filter,e,tp,m,m2,ft)
	if not filter(c) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) or not c:IsType(TYPE_RITUAL) then return false end
	if c:IsCode(210300207) and Duel.IsPlayerAffectedByEffect(tp,210300210) then m:Merge(m2) end
	local mg=m:Filter(Card.IsCanBeRitualMaterial,c,c)
	if c.ritual_custom_condition then
		return c:ritual_custom_condition(mg,ft,"greater")
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,nil)
	end
	if ft>0 then
		return mg:CheckWithSumGreater(Card.GetRitualLevel,c:GetOriginalLevel(),c)
	else
		return mg:IsExists(Auxiliary.RPGFilterF,1,nil,tp,mg,c)
	end
end
function c210300210.ritop(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetRitualMaterial(tp)
	local mg2=Duel.GetFieldGroup(tp,0,LOCATION_MZONE):Filter(Card.IsFaceup,nil):Filter(Card.IsCanBeRitualMaterial,tc,tc)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,c210300210.RPGFilter,tp,LOCATION_HAND,0,1,1,nil,aux.FilterBoolFunction(Card.IsSetCard,0xf37),e,tp,mg,mg2,ft)
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc:IsCode(210300207) and Duel.IsPlayerAffectedByEffect(tp,210300210) then mg:Merge(mg2) end
		local mat=nil
		if ft>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			mat=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetOriginalLevel(),tc)
		else
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			mat=mg:FilterSelect(tp,Auxiliary.RPGFilterF,1,1,nil,tp,mg,tc)
			Duel.SetSelectedCard(mat)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			local mat2=mg:SelectWithSumGreater(tp,Card.GetRitualLevel,tc:GetOriginalLevel(),tc)
			mat:Merge(mat2)
		end
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		if Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)>0 then
			tc:CompleteProcedure()
			e:GetHandler():CancelToGrave()
			if Duel.Equip(tp,e:GetHandler(),tc,true) then
				--Add Equip limit
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(function(e,c) return c:IsType(TYPE_RITUAL) and c:IsSetCard(0xf37) end)
				e:GetHandler():RegisterEffect(e1)
			end
		end
	end
end
function c210300210.indop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(210300210)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
