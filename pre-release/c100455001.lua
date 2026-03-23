--ファニー・ダーク・ラビット
--Funny Dark Rabbit
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--After this card is Normal or Special Summoned, you can Normal Summon 1 monster that mentions "Toon World" during your Main Phase this turn, in addition to your Normal Summon/Set (you can only gain this effect once per turn)
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetOperation(s.regop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--This card is treated as a Toon monster while "Toon World" is on the field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function() return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_TOON_WORLD),0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end)
	e2:SetValue(TYPE_TOON)
	c:RegisterEffect(e2)
	--Once per turn: You can add to your hand or place face-up on your field, 1 "Toon" Field or Continuous Spell from your Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.thpltg)
	e3:SetOperation(s.thplop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_TOON_WORLD}
s.listed_series={SET_TOON}
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.HasFlagEffect(tp,id) then return end
	local c=e:GetHandler()
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1))
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	--After this card is Normal or Special Summoned, you can Normal Summon 1 monster that mentions "Toon World" during your Main Phase this turn, in addition to your Normal Summon/Set (you can only gain this effect once per turn)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:ListsCode(CARD_TOON_WORLD) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.thplfilter(c,tp,szone_chk)
	return c:IsSetCard(SET_TOON) and (c:IsContinuousSpell() or c:IsFieldSpell()) and (c:IsAbleToHand()
		or (c:CheckUniqueOnField(tp) and not c:IsForbidden() and (c:IsFieldSpell() or szone_chk)))
end
function s.thpltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thplfilter,tp,LOCATION_DECK,0,1,nil,tp,Duel.GetLocationCount(tp,LOCATION_SZONE)>0) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thplop(e,tp,eg,ep,ev,re,r,rp)
	local szone_chk=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local sc=Duel.SelectMatchingCard(tp,s.thplfilter,tp,LOCATION_DECK,0,1,1,nil,tp,szone_chk):GetFirst()
	if sc then
		aux.ToHandOrElse(sc,tp,
			function(sc)
				return szone_chk or sc:IsFieldSpell()
			end,
			function(sc)
				if sc:IsFieldSpell() then
					local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
					if fc then
						Duel.SendtoGrave(fc,REASON_RULE)
						Duel.BreakEffect()
					end
					Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
				else
					Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
				end
			end,
			aux.Stringid(id,4)
		)
	end
end