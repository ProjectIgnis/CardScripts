--七皇転生
--Reincarnation of the Seventh Emperors
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NUMBER}
function s.confilter(c)
	if not c:IsType(TYPE_XYZ) then return false end
	local no=c.xyz_number
	return (c:IsSetCard(SET_NUMBER) and no and no>=101 and no<=107)
		or c:GetOverlayGroup():IsExists(s.confilter,1,nil)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetBattleMonster(tp)
	return bc and s.confilter(bc)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=Duel.GetBattleMonster(tp)
	local g=bc:GetOverlayGroup()
	if chk==0 then return bc:IsAbleToRemove() and (#g==0 or #g==g:FilterCount(Card.IsAbleToRemove,nil)) end
	e:SetLabelObject(bc)
	bc:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g+bc,#g,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToEffect(e) and bc:IsControler(tp) then
		Duel.Remove(bc+bc:GetOverlayGroup(),POS_FACEUP,REASON_EFFECT)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	--During the End Phase of the turn you activated this card, Special Summon 1 Rank 3 or lower Xyz Monser from your Extra Deck, and if you do, inflict damage to your opponent equal to its original ATK
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.spop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.spfilter(c,e,tp)
	return c:IsRankBelow(3) and c:IsType(TYPE_XYZ) and not c:IsSetCard(SET_NUMBER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Damage(1-tp,sc:GetBaseAttack(),REASON_EFFECT)
	end
end