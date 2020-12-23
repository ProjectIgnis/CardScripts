--光天のマハー・ヴァイロ
--Lightsky Maha Vailo
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
--Gains effects based on number of equips cards equipped to it
	--1+: Gains 1000 ATK for each equip card equipped to it
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--2+: Opponent cannot activate monster effects during battle phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.moncond)
	e2:SetValue(s.monlimit)
	c:RegisterEffect(e2)
	--3+: Negate opponent's card/effect that targets this card
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.ngcon)
	e3:SetCost(s.ngcost)
	e3:SetTarget(s.ngtg)
	e3:SetOperation(s.ngop)
	c:RegisterEffect(e3)
	--4+: Opponent cannot activate cards/effects during battle phase
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetTargetRange(0,1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.actcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--5+: Double battle damage inflicted by this card
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e5:SetCondition(s.damcon)
	e5:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e5)
end
	--Gains 1000 ATK for each equip card equipped to it
function s.val(e,c)
	return c:GetEquipCount()*1000
end
	--If 2+ equips, opponent cannot activate monster effects during battle phase
function s.moncond(e)
	local c=e:GetHandler()
	return Duel.IsBattlePhase() and c:GetEquipCount()>=2
end
function s.monlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
	--If targeted by opponent's card/effect and this card is equipped with 3+ equips
function s.ngcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		return false
	end
	local gp=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return c:GetEquipCount()>=3 and gp and gp:IsContains(c) and Duel.IsChainDisablable(ev)
end
	--Check for an equip card
function s.ngfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsAbleToGraveAsCost()
end
	--Send 1 equip card to GY as cost
function s.ngcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ngfilter,tp,LOCATION_SZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.ngfilter,tp,LOCATION_SZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
	--Activation legality
function s.ngtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
	--If 3+ equips, negate opponent's card/effect that targets this card
function s.ngop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
	--If 4+ equips, opponent cannot activate cards/effects during battle phase
function s.actcon(e)
	local c=e:GetHandler()
	local ph=Duel.GetCurrentPhase()
	return c:GetEquipCount()>=4 and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
	--If 5+ equips, this card inflicts double battle damage
function s.damcon(e)
	local c=e:GetHandler()
	return c:GetEquipCount()>=5
end
