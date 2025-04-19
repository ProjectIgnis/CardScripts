--地縛神 Ｃｕｓｉｌｌｕ (Anime)
--Earthbound Immortal Cusillu (Anime)
local s,id=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(1,1)
	e0:SetTarget(s.sumlimit)
	c:RegisterEffect(e0)
	local e1=e0:Clone()
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e1)
	local e2=e0:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e2)
	--Can Attack Directly
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetCondition(s.havefieldcon)
	c:RegisterEffect(e3)
	--Unaffected by Spell and Trap Cards
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetCondition(s.havefieldcon)
	e4:SetValue(s.unaffectedval)
	c:RegisterEffect(e4)
	--Cannot be Battle Target
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_IGNORE_BATTLE_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.havefieldcon)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--Destroy Replace and Halve Opponent's Life Points
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCode(EFFECT_DESTROY_REPLACE)
	e6:SetCondition(s.havefieldcon)
	e6:SetTarget(s.replacetg)
	c:RegisterEffect(e6)
	--Self Destroy During the End Phase
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_PHASE+PHASE_END)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCountLimit(1)
	e7:SetCondition(s.nofieldcon)
	e7:SetOperation(s.nofieldop)
	c:RegisterEffect(e7)
end
s.listed_series={SET_EARTHBOUND_IMMORTAL}
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsSetCard(SET_EARTHBOUND_IMMORTAL)
end
function s.havefieldcon(e)
	return Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.unaffectedval(e,te)
	return te:IsSpellTrapEffect() and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.replacetg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsReleasableByEffect,1,c) end
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local g=Duel.SelectReleaseGroup(tp,Card.IsReleasableByEffect,1,1,c)
		Duel.Release(g,REASON_EFFECT)
		Duel.SetLP(1-tp,Duel.GetLP(1-tp)/2)
		return true
	else return false end
end
function s.nofieldcon(e)
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
function s.nofieldop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end