--ドラグマ・パニッシュメント
--Dogmatika Punishment
--scripted by Logical Nonsense
local s,id=GetID()
function s.initial_effect(c)
	--Send 1 monster from extra deck to GY to destroy opponent's monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
	--Check for opponent's monster
function s.desfilter(c,tp)
	return c:IsFaceup() and c:GetAttack() and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_EXTRA,0,1,c,c)
end
	--Check for a monster in player's extra deck, whose ATK is higher than opponent's monster
function s.tgfilter(c,rc)
	return c:GetAttack()>=rc:GetAttack() and c:IsAbleToGrave()
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.desfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
end
	--Send 1 monster from extra deck to GY to destroy opponent's monster
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_EXTRA,0,1,1,nil,tc)
		if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	--Until the end of your next turn after this card resolves, you cannot Special Summon monsters from the Extra Deck
	local ct=Duel.IsTurnPlayer(tp) and 2 or 1
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetDescription(aux.Stringid(id,1))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e0:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN,ct)
	e0:SetTargetRange(1,0)
	e0:SetTarget(function(e,c,sump,sumtype,sumpos,targetp) return c:IsLocation(LOCATION_EXTRA) end)
	Duel.RegisterEffect(e0,tp)
end