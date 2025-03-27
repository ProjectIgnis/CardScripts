--ＣＮｏ．６２ 超銀河眼の光子龍皇
--Number C62: Neo Galaxy-Eyes Prime Photon Dragon
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),8,3,s.ovfilter,aux.Stringid(id,0))
	--Make multiple attacks this Battle Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE|PHASE_BATTLE_START)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(_,tp) return Duel.IsTurnPlayer(tp) end)
	e1:SetCost(Cost.Detach(1,1,nil))
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--Unaffected by opponent's monster effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.econ)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--Increase ATK
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
end
s.xyz_number=62
s.listed_names={31801517,CARD_GALAXYEYES_P_DRAGON}
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,31801517)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
	--Can make up to 3 attacks on monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetValue(2)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
	c:RegisterEffect(e1)
end
function s.econ(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,CARD_GALAXYEYES_P_DRAGON)
end
function s.efilter(e,te)
	return te:IsMonsterEffect() and te:GetOwnerPlayer()==1-e:GetHandlerPlayer()
end
function s.atkval(e,c)
	local g=c:GetOverlayGroup()
	local sum=g:GetSum(Card.GetLevel)+g:GetSum(Card.GetRank)
	return sum*100
end