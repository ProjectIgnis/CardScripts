--ワルキューレ・ヴリュンヒルデ
--Valkyrie Brunhilde
--scripted by Naim and AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--immune spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--gain ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--protect battle
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.ptcon)
	e3:SetTarget(s.pttg)
	e3:SetOperation(s.ptop)
	c:RegisterEffect(e3)
end
s.listed_series={0x122}
function s.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.atkval(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)*500
end
function s.ptcon(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	return at and at:IsControler(1-tp) and at:IsRelateToBattle()
end
function s.pttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chk==0 then return c:GetDefense()>=1000 end
end
function s.ptop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:UpdateDefense(-1000)==-1000 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTarget(s.ptfilter)
		e1:SetValue(1)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.ptfilter(e,c)
	return c:IsSetCard(0x122)
end

