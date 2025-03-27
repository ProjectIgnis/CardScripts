--フェイバリット・ヒーロー
--Favorite Hero
--Scripted by Randuin and AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Equip only to lvl 5+ hero
	aux.AddEquipProcedure(c,nil,s.filter)
	--Provide ATK equal to the DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(s.tgocon)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--Prevent effect target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCondition(s.tgocon)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--Activate 1 Field Spell
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE|PHASE_BATTLE_START)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.acttg)
	e3:SetOperation(s.actop)
	c:RegisterEffect(e3)
	--Second attack in a row
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.atkcon)
	e4:SetCost(Cost.SelfToGrave)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_HERO}
function s.filter(c)
	return c:IsLevelAbove(5) and c:IsSetCard(SET_HERO)
end
function s.tgocon(e)
	return Duel.GetFieldCard(e:GetHandlerPlayer(),LOCATION_FZONE,0)
end
function s.atkval(e,c)
	local def=c:GetBaseDefense()
	return def>=0 and def or 0
end
function s.actfilter(c,tp)
	return c:IsFieldSpell() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,tp) end
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sc=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	Duel.ActivateFieldSpell(sc,e,tp,eg,ep,ev,re,r,rp)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec==eg:GetFirst() and ec==Duel.GetAttacker()
		and ec:IsStatus(STATUS_OPPO_BATTLE) and ec:CanChainAttack()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChainAttack()
end