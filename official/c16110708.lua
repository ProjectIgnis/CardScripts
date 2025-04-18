--ＳＮｏ．３８ タイタニック・ギャラクシー
--Number S38: Titanic Galaxy
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 9 LIGHT monsters, or 1 "Number 38: Hope Harbinger Dragon Titanic Galaxy"
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),9,3,s.ovfilter,aux.Stringid(id,0))
	--Gains 200 ATK for each material attached to it
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,c) return c:GetOverlayCount()*200 end)
	c:RegisterEffect(e1)
	--Attach up to 2 Spells/Traps your opponent controls to this card as material
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.attachtg)
	e2:SetOperation(s.attachop)
	c:RegisterEffect(e2)
	--Make this card's original ATK become 1500 and able to attack directly
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e) return not e:GetHandler():IsBaseAttack(1500) end)
	e3:SetCost(Cost.Detach(1,1))
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3,false,REGISTER_FLAG_DETACH_XMAT)
end
s.listed_names={63767246} --"Number 38: Hope Harbinger Dragon Titanic Galaxy"
s.xyz_number=38
function s.ovfilter(c,tp,lc)
	return c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,63767246) and c:IsFaceup()
end
function s.attachfilter(c,xc,tp)
	return c:IsSpellTrap() and c:IsCanBeXyzMaterial(xc,tp,REASON_EFFECT)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and s.attachfilter(chkc,c,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.attachfilter,tp,0,LOCATION_ONFIELD,1,nil,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectTarget(tp,s.attachfilter,tp,0,LOCATION_ONFIELD,1,2,nil,c,tp)
	local tc1,tc2=g:GetFirst(),g:GetNext()
	Duel.SetChainLimit(function(e,rp,tp) local rc=e:GetHandler() return rc~=tc1 and rc~=tc2 end)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	local tg=Duel.GetTargetCards(e):Filter(s.attachfilter,nil,c,tp):Remove(Card.IsImmuneToEffect,nil,e)
	if #tg>0 then
		Duel.Overlay(c,tg,true)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		if c:IsFaceup() then
			--Its original ATK becomes 1500 until the end of this turn
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK)
			e1:SetValue(1500)
			e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
			c:RegisterEffect(e1)
		end
		--It can attack directly this turn
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(3205)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e2)
	end
end