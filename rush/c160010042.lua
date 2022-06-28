-- 暴れ牛鬼
-- Abare Ushioni (Rush)
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Inflict damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COIN+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
s.toss_coin=true
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_EITHER,1000)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=math.abs(tp-Duel.TossCoin(tp,1))
	Duel.Damage(p,1000,REASON_EFFECT)
end