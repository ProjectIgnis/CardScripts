--クリオスフィンクス
--Criosphinx
local s,id=GetID()
function s.initial_effect(c)
	--reg
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetTarget(s.hdtg)
	e2:SetOperation(s.hdop)
	c:RegisterEffect(e2)
end
function s.filter(c,tp)
	return c:IsControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsMonster()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local p1=false local p2=false
	if eg:IsExists(s.filter,1,nil,0) then p1=true end
	if eg:IsExists(s.filter,1,nil,1) then p2=true end
	local c=e:GetHandler()
	if p1 and p2 then
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,re,r,rp,PLAYER_ALL,0)
	elseif p1 then
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,re,r,rp,0,0)
	elseif p2 then
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,re,r,rp,1,0)
	end
end
function s.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,ep,LOCATION_HAND)
end
function s.hdop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	if ep==PLAYER_ALL then
		Duel.DiscardHand(0,nil,1,1,REASON_EFFECT)
		Duel.DiscardHand(1,nil,1,1,REASON_EFFECT)
	else
		Duel.DiscardHand(ep,nil,1,1,REASON_EFFECT)
	end
end