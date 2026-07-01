--ドラゴン・アイス
--Dragon Ice
local s,id=GetID()
function s.initial_effect(c)
	--There can only be 1 "Dragon Ice" on the field
	c:SetUniqueOnField(1,1,id)
	--When your opponent Special Summons a monster (except during the Damage Step): You can discard 1 card; Special Summon this card from your hand or Graveyard
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCondition(function(e,tp,eg)
		return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
	end)
	e1:SetCost(Cost.Discard(function(c,e,tp)
		local dragon_ice=e:GetHandler()
		return dragon_ice:IsLocation(LOCATION_GRAVE) or dragon_ice:IsAbleToGraveAsCost() or c~=dragon_ice
	end))
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	c:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end