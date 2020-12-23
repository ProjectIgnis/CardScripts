--ＣｉＮｏ．１０００ 夢幻虚光神ヌメロニアス・ヌメロニア
--Number iC1000: Numeronius Numeronia
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,13,5)
	c:EnableReviveLimit()
	--atk/def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.adcon)
	e1:SetValue(100000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--atk restriction
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_MUST_ATTACK)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atcon)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e4:SetValue(s.attg)
	c:RegisterEffect(e4)
	--win
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetCountLimit(1)
	e5:SetCondition(s.wincon)
	e5:SetOperation(s.winop)
	c:RegisterEffect(e5)
	--negate attack
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,0))
	e7:SetCategory(CATEGORY_RECOVER)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e7:SetCode(EVENT_ATTACK_ANNOUNCE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(s.nacon)
	e7:SetCost(s.nacost)
	e7:SetTarget(s.natg)
	e7:SetOperation(s.naop)
	c:RegisterEffect(e7,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_series={0x48}
s.listed_names={100275101}
s.xyz_number=1000
function s.adcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+0x53b) and not Duel.IsTurnPlayer(e:GetHandlerPlayer())
end
function s.atcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+0x53b) and Duel.GetTurnCount()>e:GetHandler():GetTurnID()
end
function s.attg(e,c)
	return c==e:GetHandler()
end
function s.wincon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsTurnPlayer(tp) and e:GetHandler():GetBattledGroupCount()==0 and s.atcon(e)
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(tp,WIN_REASON_NUMBER_iC1000)
end
function s.nacon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.GetAttacker():IsControler(tp)
end
function s.nacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.natg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetAttacker():IsOnField() end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,Duel.GetAttacker():GetAttack())
end
function s.naop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateAttack() then
		Duel.Recover(tp,Duel.GetAttacker():GetAttack(),REASON_EFFECT)
	end
end
