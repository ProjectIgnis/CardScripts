--王の棺
--King's Sarcophagus
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Your "Horus" monsters cannot be destroyed by effects that do not target them
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_HORUS))
	e2:SetValue(s.indvalue)
	c:RegisterEffect(e2)
	--Send 1 "Horus" monster from the Deck to the GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(4,id)
	e3:SetCost(s.dtgcost)
	e3:SetTarget(s.dtgtg)
	e3:SetOperation(s.dtgop)
	c:RegisterEffect(e3)
	--Send to the GY an opponent's monster that battles your "Horus" monster
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.btgcond)
	e4:SetTarget(s.btgtg)
	e4:SetOperation(s.btgop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_HORUS}
function s.indvalue(e,re,rp,c)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g:IsContains(c)
end
function s.dtgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST,nil)
end
function s.tgfilter(c)
	return c:IsSetCard(SET_HORUS) and c:IsMonster() and c:IsAbleToGrave()
end
function s.dtgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.dtgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function s.btgcond(e,tp,eg,ep,ev,re,r,rp)
	local a,at=Duel.GetBattleMonster(tp)
	return a and at and a:IsSetCard(SET_HORUS) and a:IsFaceup()
end
function s.btgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local a,at=Duel.GetBattleMonster(tp)
	if chk==0 then return at and at:IsAbleToGrave() end
	e:SetLabelObject(at)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,at,1,tp,0)
end
function s.btgop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsRelateToBattle() and tc:IsControler(1-tp) then
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end