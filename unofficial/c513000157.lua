--Ｓｐ－タイラント・フォース (Anime)
--Speed Spell - Tyrant Force (Anime)
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFieldCard(e:GetHandler():GetControler(),LOCATION_FZONE,0)
	return tc and tc:GetCounter(0x91)>9
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	Duel.RegisterEffect(e2,tp)
	--Inflict 300 to opponent each time their card(s) is destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(s.damcon)
	e3:SetOperation(s.damop)
	e3:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e3,tp)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsPreviousControler,1,nil,1-tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(Card.IsPreviousControler,nil,1-tp)
	Duel.Damage(1-tp,ct*300,REASON_EFFECT)
end