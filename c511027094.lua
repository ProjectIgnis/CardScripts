--アローザル・ハイドライブ・モナーク
--Rousing Hydradrive Monarch
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x577)
	--link summon
	c:EnableReviveLimit()
	Link.AddProcedure(c,s.matfilter,4,4)
	--Adds Attributes
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_ADD_ATTRIBUTE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(0xe)
	c:RegisterEffect(e0)
	--place hydradrive counters when summoned and add attributes
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.ctcon)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--Attack Position restriction
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTarget(s.sumlimit)
	e2:SetTargetRange(1,1)
	e2:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_FORCE_NORMAL_SUMMON_POSITION)
	c:RegisterEffect(e3)
	--Dice + send to GY
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DICE+CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(s.dicecost)
	e4:SetCondition(s.dicecon)
	e4:SetTarget(s.dicetg)
	e4:SetOperation(s.diceop)
	c:RegisterEffect(e4)
	--disable/0 ATK
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DISABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetTarget(s.distarget)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_SET_ATTACK_FINAL)
	e6:SetValue(0)
	c:RegisterEffect(e6)
end
function s.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0x577) and c:IsType(TYPE_LINK)
end
function s.attcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP) and e:GetHandler():IsLocation(LOCATION_MZONE)
end 
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_EXTRA)
end
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,4,0,0x577)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
	   c:AddCounter(0x577,4)   
	end
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
   return (c:GetAttribute()&e:GetHandler():GetAttribute())~=0
end
function s.dicecon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0x577)>0 and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
function s.sgfilter(c,att)
	return c:IsAbleToGrave() and c:IsAttribute(att)
end
function s.dicecost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x577,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x577,1,REASON_COST)
end
function s.dicetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local sg=Duel.GetMatchingGroup(s.sgfilter,tp,0,LOCATION_MZONE,nil,att)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,sg,#sg,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,#sg*500)
end
function s.diceop(e,tp,eg,ep,ev,re,r,rp)
	local dice=Duel.TossDice(tp,1)
	local att
	if dice==1 then att=ATTRIBUTE_EARTH end
	if dice==2 then att=ATTRIBUTE_WATER end
	if dice==3 then att=ATTRIBUTE_FIRE end
	if dice==4 then att=ATTRIBUTE_WIND end
	if dice==5 then att=ATTRIBUTE_LIGHT end
	if dice==6 then att=ATTRIBUTE_DARK end
	local g=Duel.GetMatchingGroup(s.sgfilter,tp,0,LOCATION_ONFIELD,nil,att)
	if Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		local dc=Duel.GetOperatedGroup()
		Duel.Damage(1-tp,#dc*500,REASON_EFFECT)
	end  
end
function s.distarget(e,c)
	return c:IsAttribute(e:GetHandler():GetAttribute()) and c:IsType(TYPE_EFFECT)
end