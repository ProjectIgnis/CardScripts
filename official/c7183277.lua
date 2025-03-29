--ライトロード・ドルイド オルクス
--Aurkus, Lightsworn Druid
local s,id=GetID()
function s.initial_effect(c)
	--Neither player can target "Lightsworn" monsters (anywhere) with card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(function(_,c) return c:IsSetCard(SET_LIGHTSWORN) and c:IsMonster() and c:IsFaceup() end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Send the top 2 cards of your Deck to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(_,tp) return Duel.IsTurnPlayer(tp) end)
	e2:SetTarget(s.distg)
	e2:SetOperation(function(_,tp) Duel.DiscardDeck(tp,2,REASON_EFFECT) end)
	c:RegisterEffect(e2)
end
s.listed_series={SET_LIGHTSWORN}
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end