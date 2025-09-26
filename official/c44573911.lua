--JP name
--R.B. Ga10 Pile Bunker
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--If you control no face-up monsters, or the only face-up monsters you control are "R.B." monsters, you can Special Summon this card (from your hand)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--Destroy all cards your opponent controls and this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.descon)
	e2:SetCost(Cost.PayLP(1500))
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_RB}
s.listed_names={32216688} --"R.B. The Brute Blues"
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and (#g==0 or g:FilterCount(Card.IsSetCard,nil,SET_RB)==#g)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local bc,oc=Duel.GetBattleMonster(tp)
	return bc and oc and bc:IsCode(32216688) and bc:GetLinkedGroup():IsContains(e:GetHandler())
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g+e:GetHandler(),#g,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	if c:IsRelateToEffect(e) and #g>0 then
		g:AddCard(c)
		Duel.Destroy(g,REASON_EFFECT)
	end
end