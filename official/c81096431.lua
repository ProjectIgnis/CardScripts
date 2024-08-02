--ドレイク・シャーク
--Drake Shark
--scripted by Naim
local EFFECT_DOUBLE_XYZ_MATERIAL=511001225 --to be removed when the procedure is updated
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card if it is added to the hand, except by drawing it
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return not e:GetHandler():IsReason(REASON_DRAW) end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Can be treated as 2 Materials for the Xyz Summon of a WATER Xyz monter that requires 3 or more materials
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_XYZ_MATERIAL)
	e2:SetValue(1)
	e2:SetCondition(function(e) return not Duel.HasFlagEffect(e:GetHandlerPlayer(),id) end)
	e2:SetOperation(function(e,c,matg) return c:IsAttribute(ATTRIBUTE_WATER) and c.minxyzct and c.minxyzct>=3 and matg:FilterCount(s.drakesharkhoptfilter,nil)<2 end)
	c:RegisterEffect(e2)
	--Provide an effect to a "Shark Drake" Xyz Monster that this card as Xyz material
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e) return e:GetHandler():IsSetCard(SET_SHARK_DRAKE) end)
	e3:SetCost(aux.dxmcostgen(2,2,nil))
	e3:SetTarget(s.attachtg)
	e3:SetOperation(s.attachop)
	c:RegisterEffect(e3)
	--HOPT workaround for having already used the double material effect earlier in that turn
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(s.valcheck)
		Duel.RegisterEffect(ge1,0)
	end)
end
s.listed_series={SET_SHARK_DRAKE}
function s.drakesharkhoptfilter(c)
	return c:IsCode(id) and c:IsHasEffect(EFFECT_DOUBLE_XYZ_MATERIAL)
end
function s.valcheck(e,c)
	if not (c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_WATER) and c.minxyzct and c.minxyzct>=3) then return end
	local g=c:GetMaterial()
	if #g<c.minxyzct and g:IsExists(s.drakesharkhoptfilter,1,nil) then
		Duel.RegisterFlagEffect(c:GetControler(),id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.attachfilter(c,tp)
	return c:IsSpellTrap() and (c:IsControler(tp) or c:IsAbleToChangeControler())
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsOnField() and s.attachfilter(chkc,tp) end
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ)
		and Duel.IsExistingTarget(s.attachfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACH)
	Duel.SelectTarget(tp,s.attachfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and c:IsType(TYPE_XYZ) then
		Duel.Overlay(c,tc)
	end
end