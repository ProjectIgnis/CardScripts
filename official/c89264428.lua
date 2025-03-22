--ベアルクティ・ビッグディッパー
--Ursarctic Big Dipper
--Scripted by Eerie Code
local s,id=GetID()
local COUNTER_BIG_DIPPER=0x204
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_BIG_DIPPER)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Once per turn, if your "Ursarctic" monster would Tribute a monster(s) to activate its effect, you can banish 1 Level 7 or higher "Ursarctic" monster from your GY instead
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(CARD_URSARCTIC_BIG_DIPPER)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(1,0)
	e1:SetCountLimit(1)
	e1:SetCondition(s.repcon)
	e1:SetValue(s.repval)
	e1:SetOperation(s.repop)
	c:RegisterEffect(e1)
	--Each time a monster(s) is Special Summoned, place 1 counter on this card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(function(e) e:GetHandler():AddCounter(COUNTER_BIG_DIPPER,1) end)
	c:RegisterEffect(e2)
	--Take control of 1 monster your opponent controls
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_CONTROL)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.ctrlcost)
	e3:SetTarget(s.ctrltg)
	e3:SetOperation(s.ctrlop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_URSARCTIC}
s.counter_place_list={COUNTER_BIG_DIPPER}
function s.repconfilter(c,extracon,base,e,tp,eg,ep,ev,re,r,rp)
	return c:IsLevelAbove(7) and c:IsSetCard(SET_URSARCTIC) and c:IsAbleToRemoveAsCost()
		and (extracon==nil or extracon(base,e,tp,eg,ep,ev,re,r,rp,c))
end
function s.repcon(e)
	return Duel.IsExistingMatchingCard(s.repconfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
function s.repval(base,e,tp,eg,ep,ev,re,r,rp,chk,extracon)
	local c=e:GetHandler()
	return c:IsSetCard(SET_URSARCTIC) and c:IsMonster()
		and (extracon==nil or Duel.IsExistingMatchingCard(s.repconfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,extracon,base,e,tp,eg,ep,ev,re,r,rp))
end
function s.repop(base,e,tp,eg,ep,ev,re,r,rp,chk,extracon)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.repconfilter,tp,LOCATION_GRAVE,0,1,1,nil,extracon,base,e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_REPLACE)
end
function s.ctrlcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,COUNTER_BIG_DIPPER,7,REASON_COST) end
	c:RemoveCounter(tp,COUNTER_BIG_DIPPER,c:GetCounter(COUNTER_BIG_DIPPER),REASON_COST)
end
function s.ctrlconfilter(c)
	return c:IsSetCard(SET_URSARCTIC) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
function s.ctrltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsControlerCanBeChanged() end
	if chk==0 then return Duel.IsExistingMatchingCard(s.ctrlconfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,tp,0)
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp)
	end
end