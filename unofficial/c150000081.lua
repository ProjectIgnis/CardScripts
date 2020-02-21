--バブルボム・メモリー
--Bubble Bomb Memory
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetHintTiming(0,0x1e0)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		s.effDamage={}
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_DAMAGE)
		e1:SetOperation(s.op)
		Duel.RegisterEffect(e1,0)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_TURN_END)
		e2:SetOperation(s.reset)
		Duel.RegisterEffect(e2,0)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if r&REASON_EFFECT>0 and ev>0 then
		table.insert(s.effDamage,ev)
	end
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	s.effDamage={}
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return #s.effDamage>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local d=Duel.AnnounceNumber(tp,table.unpack(s.effDamage))
	Duel.Damage(p,d,REASON_EFFECT)
end
