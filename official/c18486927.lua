--古代の歯車機械
--Ancient Gear Gadget
local s,id=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can declare 1 card type (Monster, Spell, or Trap); this turn, if your monster attacks, your opponent cannot activate Spell/Trap Cards or monster effects (whichever was declared) until the end of the Damage Step
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.dectg)
	e1:SetOperation(s.decop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Once per turn: You can declare 1 "Gadget" monster's card name; until the End Phase, this card's name becomes that name
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.nametg)
	e3:SetOperation(s.nameop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_GADGET}
function s.dectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	e:GetChainData().choice=Duel.SelectOption(tp,70,71,72)
end
function s.decop(e,tp,eg,ep,ev,re,r,rp)
	local cd=e:GetChainData()
	local typ=1<<cd.choice
	--This turn, if your monster attacks, your opponent cannot activate Spell/Trap Cards or monster effects (whichever was declared) until the end of the Damage Step
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,cd.choice+2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(function(e)
		local ac=Duel.GetAttacker()
		return ac and ac:IsControler(e:GetHandlerPlayer())
	end)
	e1:SetValue(function(e,re) return re:IsActiveType(typ) and (ct==TYPE_MONSTER or re:IsHasType(EFFECT_TYPE_ACTIVATE)) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.nametg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local code=e:GetHandler():GetCode()
	Duel.AnnounceCard(tp,DF.IsType(TYPE_MONSTER) & DF.IsSetCard(SET_GADGET) & ~DF.IsCode(code))
end
function s.nameop(e,tp,eg,ep,ev,re,r,rp)
	local cd=e:GetChainData()
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		--Until the End Phase, this card's name becomes that name
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(cd.announced_card)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
	end
end
