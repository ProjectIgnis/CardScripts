--旧神ノーデン
--Elder Entity Norden
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 Synchro or Xyz Monster + 1 Synchro or Xyz Monster
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO|TYPE_XYZ),2)
	--When this card is Special Summoned from the Extra Deck: You can target 1 Level 4 or lower monster in your GY; Special Summon it, but its effects are negated, also banish it when this card leaves the field. You can only use this effect of "Elder Entity Norden" once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e)
		return e:GetHandler():IsSummonLocation(LOCATION_EXTRA)
	end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.miracle_synchro_fusion=true
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
		--Its effects are negated
		tc:NegateEffects(c)
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			c:SetCardTarget(tc)
			c:CreateRelation(tc,RESET_EVENT|RESET_OVERLAY|RESET_MSCHANGE|RESET_TURN_SET)
			tc:CreateRelation(c,RESET_EVENT|RESETS_STANDARD|RESET_OVERLAY)
			--Also banish it when this card leaves the field
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_LEAVE_FIELD_P)
			e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
				--Register the banishing effect only if its effects aren't negated right before it leaves the field
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_LEAVE_FIELD)
				e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
					if c:IsRelateToCard(tc) and tc:IsRelateToCard(c) then
						c:ReleaseRelation(tc)
						Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
					end
					e:Reset()
				end)
				e1:SetReset(RESET_EVENT|(RESET_OVERLAY|RESET_MSCHANGE|RESET_TURN_SET))
				c:RegisterEffect(e1)
			end)
			e1:SetReset(RESET_EVENT|(RESET_OVERLAY|RESET_MSCHANGE|RESET_TURN_SET))
			c:RegisterEffect(e1)
		end
	end
	Duel.SpecialSummonComplete()
end