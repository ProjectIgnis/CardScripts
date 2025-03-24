--羅睺星辰
--Rahu Dragontail
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	local params={handler=c,fusfilter=aux.FilterBoolFunction(Card.IsSetCard,SET_DRAGONTAIL),extrafil=s.extramat,stage2=s.summonlimit,extratg=s.extratg}
	--Fusion Summon 1 "Dragontail" Fusion Monster from your Extra Deck, using monsters from your hand, Deck, and/or field
	local e1=Fusion.CreateSummonEff(params)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DRAGONTAIL}
function s.extramat(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
end
function s.extratg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end
function s.summonlimit(e,tc,tp,mg,chk)
	if chk==2 then
		if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
		--You cannot Special Summon from the Extra Deck for the rest of this turn after this card resolves, except Fusion Monsters
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end