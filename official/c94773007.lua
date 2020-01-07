--地雷蜘蛛
local s,id=GetID()
function s.initial_effect(c)
	--coin
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(s.attg)
	e1:SetOperation(s.atop)
	c:RegisterEffect(e1)
end
s.toss_coin=true
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.SelectOption(tp,60,61)
	local coin=Duel.TossCoin(tp,1)
	if opt==coin then
		Duel.SetLP(tp,math.ceil(Duel.GetLP(tp)/2))
	end
end
