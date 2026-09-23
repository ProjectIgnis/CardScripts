--シャイニング・アンブラル
--Shining Umbral Horror
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--If you Normal or Special Summon an "Umbral Horror" monster(s) and/or a "Masquerade" Xyz Monster(s): You can Special Summon this card from your hand, and if you do, draw 1 card, then if you drew an "Umbral Horror" monster, you can Special Summon it
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetRange(LOCATION_HAND)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetCondition(s.spcon)
	e1a:SetTarget(s.sptg)
	e1a:SetOperation(s.spop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--Can be treated as 2 materials for the Xyz Summon of a "Number" Xyz Monster that requires 3 or more materials
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DOUBLE_XYZ_MATERIAL)
	e2:SetValue(1)
	e2:SetCountLimit(1,{id,1})
	e2:SetOperation(function(e,c)
		return c.minxyzct and c.minxyzct>=3 and c:IsSetCard(SET_NUMBER)
	end)
	c:RegisterEffect(e2)
end
s.listed_series={SET_UMBRAL_HORROR,SET_MASQUERADE,SET_NUMBER}
function s.spconfilter(c,tp)
	return (c:IsSetCard(SET_UMBRAL_HORROR) or (c:IsSetCard(SET_MASQUERADE) and c:IsXyzMonster()))
		and c:IsSummonPlayer(tp) and c:IsFaceup()
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spconfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.Draw(tp,1,REASON_EFFECT)>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		local drawn_card=Duel.GetOperatedGroup():GetFirst()
		if drawn_card:IsSetCard(SET_UMBRAL_HORROR) and drawn_card:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			if not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return Duel.ShuffleHand(tp) end
			Duel.BreakEffect()
			Duel.SpecialSummon(drawn_card,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end