--マジスタリー・アルケミスト
--Magistry Alchemist
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x8}
function s.costfilter(c,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsSetCard(0x8) and c:IsFaceup() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true,true)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x8) and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP)
end
function s.spcheck(sg,e,tp)
	return aux.ChkfMMZ(1)(sg,e,tp) and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,sg,e,tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-4 and #rg>3 and aux.SelectUnselectGroup(rg,e,tp,4,4,s.spcheck,0) end
	local g=aux.SelectUnselectGroup(rg,e,tp,4,4,s.spcheck,1,tp,HINTMSG_REMOVE)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabelObject(g)
	g:KeepAlive()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local g=e:GetLabelObject()
		if Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP)
			and g and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_EARTH)
			and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WATER)
			and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_FIRE)
			and g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WIND) then
			local atk=tc:GetBaseAttack()
			--double original ATK
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK)
			e1:SetValue(atk*2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			local ng=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
			if #ng>0 then
				for tcn in aux.Next(ng) do
					--negate opponent's face-up cards
					local e2=Effect.CreateEffect(e:GetHandler())
					e2:SetType(EFFECT_TYPE_SINGLE)
					e2:SetCode(EFFECT_DISABLE)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD)
					tcn:RegisterEffect(e2)
					local e3=Effect.CreateEffect(e:GetHandler())
					e3:SetType(EFFECT_TYPE_SINGLE)
					e3:SetCode(EFFECT_DISABLE_EFFECT)
					e3:SetReset(RESET_EVENT+RESETS_STANDARD)
					tcn:RegisterEffect(e3)
				end
			end
			g:DeleteGroup()
		end
		Duel.SpecialSummonComplete()
	end
end
