--覇王門零 (Anime)
--Supreme King Gate Zero (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum procedure
	Pendulum.AddProcedure(c)
	--While you control a monster, you cannot Pendulum Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e0:SetRange(LOCATION_PZONE)
	e0:SetTargetRange(1,0)
	e0:SetCondition(function(e) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>0 end)
	e0:SetTarget(function(e,c,sump,sumtype,sumpos,targetp) return (sumtype&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM end)
	c:RegisterEffect(e0)
	--While you control a "Supreme King" monster, you take no damage
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1a:SetCode(EFFECT_CHANGE_DAMAGE)
	e1a:SetRange(LOCATION_PZONE)
	e1a:SetTargetRange(1,0)
	e1a:SetLabel(0)
	e1a:SetCondition(function(e) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,0xf8),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) end)
	e1a:SetValue(s.damval)
	c:RegisterEffect(e1a)
	--Handling for "Supreme King Gate Infinity (Anime)"	for above effect application
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1b:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1b:SetCode(EVENT_ADJUST)
	e1b:SetRange(LOCATION_PZONE)
	e1b:SetLabelObject(e1a)
	e1b:SetOperation(s.trig)
	c:RegisterEffect(e1b)
	--Add 1 "Supreme King Gate Infinity" from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_MZONE) and e:GetHandler():IsFaceup() end)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.listed_series={0xf8} --"Supreme King" archetype
s.listed_names={22211622} --"Supreme King Gate Infinity"
function s.damval(e,re,val,r,rp,rc)
	local tp=e:GetHandlerPlayer()
	if val~=0 then
		e:SetLabel(val)
		return 0
	else return val end
end
function s.trig(e,tp,eg,ep,ev,re,r,rp)
	local val=e:GetLabelObject():GetLabel()
	if val~=0 then
		Duel.RaiseEvent(e:GetHandler(),96227613,e,REASON_EFFECT,tp,tp,val)
		e:GetLabelObject():SetLabel(0)
	end
end
function s.thfilter(c)
	return c:IsCode(22211622) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
