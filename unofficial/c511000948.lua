--主従の覚悟
--Master and Servant's Resolve
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--During the Battle Phase, when a monster is destroyed by an Effect Monster's effect, the destroyed monster's controller takes damage equal to its ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.IsBattlePhase() and re and re:IsMonsterEffect() and eg:IsExists(Card.IsMonster,1,nil) end)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	--During each of your Standby Phases, take 1000 damage or destroy this card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e2:SetOperation(s.maintop)
	c:RegisterEffect(e2)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(Card.IsMonster,nil)
	local g1,g2=g:Split(Card.IsPreviousControler,nil,tp)
	local dam1,dam2=g1:GetSum(Card.GetPreviousAttackOnField),g2:GetSum(Card.GetPreviousAttackOnField)
	local self_chk=dam1>0 and #g1>0
	local opp_chk=dam2>0 and #g2>0
	local player=(self_chk and opp_chk and PLAYER_ALL)
		or (self_chk and tp)
		or (opp_chk and 1-tp)
	local chain_link=Duel.GetCurrentChain()
	s[chain_link]={dam1,dam2}
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,player,dam1+dam2)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local chain_link=Duel.GetCurrentChain()
	local dam1,dam2=table.unpack(s[chain_link])
	if dam1>0 then
		Duel.Damage(tp,dam1,REASON_EFFECT,true)
	end
	if dam2>0 then
		Duel.Damage(1-tp,dam2,REASON_EFFECT,true)
	end
	Duel.RDComplete()
end
function s.maintop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	--Take 1000 damage or destroy this card
	local op=Duel.SelectEffect(tp,
		{true,aux.Stringid(id,1)},
		{true,aux.Stringid(id,2)}) or 2
	if op==1 then
		Duel.Damage(tp,1000,REASON_COST)
	elseif op==2 then
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end