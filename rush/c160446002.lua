--時の魔術師
--Time Wizard (Rush)
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_COIN|CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
s.toss_coin=true
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local res=Duel.TossCoin(tp,1)
	if res==COIN_HEADS then
		local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
		Duel.Destroy(g,REASON_EFFECT)
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,0,tp,0)
	elseif res==COIN_TAILS then
		local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
		Duel.Destroy(g,REASON_EFFECT)
		local dg=Duel.GetOperatedGroup()
		local sum=dg:GetSum(Card.GetBaseAttack)
		Duel.Damage(tp,sum,REASON_EFFECT)
	end
end