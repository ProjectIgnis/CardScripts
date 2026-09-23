--七皇の冀望郷
--Seventh Barian's
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Each player can only Special Summon non-"Number" monsters from the Extra Deck twice per turn while this card is face-up on the field
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1a:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1a:SetRange(LOCATION_FZONE)
	e1a:SetTargetRange(1,1)
	e1a:SetTarget(function(e,c,summon_player,sumtype,sumpos,targetp,se)
		return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(SET_NUMBER) and e:GetHandler():HasFlagEffect(id+summon_player,2)
	end)
	c:RegisterEffect(e1a)
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1b:SetRange(LOCATION_FZONE)
	e1b:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		for sc in eg:Iter() do
			if sc:IsSummonLocation(LOCATION_EXTRA) and (not sc:IsSetCard(SET_NUMBER) or sc:IsFacedown()) then
				local summon_player=sc:GetSummonPlayer()
				e:GetHandler():RegisterFlagEffect(id+summon_player,RESETS_STANDARD_PHASE_END,0,1)
			end
		end
	end)
	c:RegisterEffect(e1b)
	local e1c=Effect.CreateEffect(c)
	e1c:SetType(EFFECT_TYPE_FIELD)
	e1c:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1c:SetCode(EFFECT_LEFT_SPSUMMON_COUNT)
	e1c:SetRange(LOCATION_FZONE)
	e1c:SetTargetRange(1,1)
	e1c:SetValue(function(e,re,tp)
		return math.max(2-e:GetHandler():GetFlagEffect(id+tp),0)
	end)
	c:RegisterEffect(e1c)
	--During your Main Phase: You can add 1 "Umbral Horror" monster from your Deck to your hand, then discard 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--During the End Phase: Each player takes 400 damage for each Xyz Monster on the field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return true end
		local dam=400*Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsXyzMonster),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,dam)
	end)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local dam=400*Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsXyzMonster),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if dam>0 then
			Duel.Damage(tp,dam,REASON_EFFECT,true)
			Duel.Damage(1-tp,dam,REASON_EFFECT,true)
			Duel.RDComplete()
		end
	end)
	c:RegisterEffect(e3)
end
s.listed_series={SET_NUMBER,SET_UMBRAL_HORROR}
function s.thfilter(c)
	return c:IsSetCard(SET_UMBRAL_HORROR) and c:IsMonster() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)
	end
end