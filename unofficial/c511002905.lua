--ネジマキの爆弾
--Gearspring Exploder
local s,id=GetID()
local COUNTER_GEARSPRING=0x107
function s.initial_effect(c)
	--Inflict 800 damage to your opponent for each Gearspring Counter on your side of the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return Duel.IsTurnPlayer(tp) and eg:IsExists(Card.IsControler,1,nil,tp) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.counter_list={COUNTER_GEARSPRING}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetCounter(tp,1,0,COUNTER_GEARSPRING)
	if chk==0 then return ct>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*800)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetCounter(tp,1,0,COUNTER_GEARSPRING)
	if ct>0 then
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		Duel.Damage(p,ct*800,REASON_EFFECT)
	end
end