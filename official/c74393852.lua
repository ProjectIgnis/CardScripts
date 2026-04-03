--十二獣ワイルドボウ
--Zoodiac Boarbow
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 5 Level 4 monsters (or 1 "Zoodiac" monster you control with a different name)
	Xyz.AddProcedure(c,nil,4,5,s.ovfilter,aux.Stringid(id,0),nil,s.xyzop)
	--This card gains the ATK/DEF of all "Zoodiac" monsters attached to it as its materials
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetValue(s.atkval)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	e1b:SetValue(s.defval)
	c:RegisterEffect(e1b)
	--This card can attack directly
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	--When this card inflicts battle damage to your opponent while it has 12 or more Xyz Materials: You can send as many cards as possible from your opponent's hand and field to the Graveyard, then change this card to Defense Position.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ZOODIAC}
s.listed_names={id}
function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(SET_ZOODIAC,lc,SUMMON_TYPE_XYZ,tp) and not c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,id)
end
function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	return true
end
function s.atkfilter(c)
	return c:IsSetCard(SET_ZOODIAC) and c:HasNonZeroAttack()
end
function s.atkval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(s.atkfilter,nil)
	return g:GetSum(Card.GetAttack)
end
function s.deffilter(c)
	return c:IsSetCard(SET_ZOODIAC) and c:HasNonZeroDefense()
end
function s.defval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(s.deffilter,nil)
	return g:GetSum(Card.GetDefense)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and e:GetHandler():GetOverlayCount()>=12
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND|LOCATION_ONFIELD)
	if chk==0 then return #g>0 end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND|LOCATION_ONFIELD)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		if og:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)==0 then return end
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			Duel.BreakEffect()
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		end
	end
end
