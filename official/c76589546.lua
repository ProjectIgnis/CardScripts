--オーバーフロー・ドラゴン
--Overflow Dragon
--Scripted by Eerie Code
local s,id=GetID()
local TOKEN_OVERFLOW=id+1
function s.initial_effect(c)
	--When a monster(s) on the field is destroyed by card effect (except during the Damage Step): You can Special Summon this card from your hand, then, if 2 or more monsters on the field were destroyed by that card effect, you can Special Summon 1 "Overflow Token" (Dragon/DARK/Level 1/ATK 0/DEF 0). You can only use this effect of "Overflow Dragon" once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.listed_names={TOKEN_OVERFLOW}
function s.spconfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spconfilter,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	if eg:IsExists(s.spconfilter,2,nil) then
		e:SetLabel(1)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,tp,0)
	else
		e:SetLabel(0)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetLabel()==1
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_OVERFLOW,0,TYPES_TOKEN,0,0,1,RACE_DRAGON,ATTRIBUTE_DARK)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local token=Duel.CreateToken(tp,TOKEN_OVERFLOW)
		Duel.BreakEffect()
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end