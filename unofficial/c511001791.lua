--覇王黒竜オッドアイズ・リベリオン・ドラゴン (Anime)
--Odd-Eyes Rebellion Dragon (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 7 Dragon monsters 
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON),7,2)
	--Pendulum procedure
	Pendulum.AddProcedure(c,false)
	--Place 1 Pendulum monster from your Deck in your other Pendulum Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
	--Destroy Level 7 or lower monsters your opponent controls to inflict damage
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() and e:GetLabel()==1 end)
	e2:SetTarget(s.xyzsumdestg)
	e2:SetOperation(s.xyzsumdesop)
	c:RegisterEffect(e2)
	--Check if an Xyz Monster that was treated as a Level 7 monster was used as material
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	--This card can attack a number of times each Battle Phase this turn, up to the current number of monsters destroyed in your opponent's possession
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(function(e) return Duel.IsAbleToEnterBP() and s[1-e:GetHandlerPlayer()]>0 end)
	e4:SetCost(Cost.Detach(1))
	e4:SetTarget(s.atktg)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
	--Destroy all other cards in your Pendulum Zones, then place this card in your Pendulum Zone
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end) 
	e5:SetTarget(s.pentg)
	e5:SetOperation(s.penop)
	c:RegisterEffect(e5)
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		aux.AddValuesReset(function()
			s[0]=0
			s[1]=0
		end)
	end)
end
function s.chkfilter(c,tp,tid)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:GetTurnID()==tid
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tid=Duel.GetTurnCount()
	local g=eg:Filter(s.chkfilter,nil,1-tp,tid)
	if #g>0 then
		s[1-tp]=s[1-tp]+#g
	end
end
function s.plfilter(c)
    return c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) and Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	if not (e:GetHandler():IsRelateToEffect(e) or Duel.CheckPendulumZones(tp)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.xyzsumdesfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(7)
end
function s.xyzsumdestg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.xyzsumdesfilter,tp,0,LOCATION_MZONE,nil)
	local atk=g:GetSum(Card.GetAttack)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
function s.xyzsumdesop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.xyzsumdesfilter,tp,0,LOCATION_MZONE,nil)
	if Duel.Destroy(g,REASON_EFFECT)>0 then
		local dg=Duel.GetOperatedGroup()
		local sum=dg:GetSum(Card.GetPreviousAttackOnField)
		Duel.Damage(1-tp,sum,REASON_EFFECT)
	end
end
function s.matfilter(c,sc)
	return c:IsType(TYPE_XYZ,sc,SUMMON_TYPE_XYZ) and c:IsXyzLevel(c,7)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(s.matfilter,1,nil,c) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0 end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(s[1-tp]-1)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if Duel.Destroy(g,REASON_EFFECT)>0 and Duel.CheckPendulumZones(tp) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
