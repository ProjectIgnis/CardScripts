--セブンスロード・プロテクション
--Sevens Road Protection
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_SEVENS_ROAD_MAGICIAN}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
function s.dspfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup() and c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dspfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,eg:GetFirst(),1,0,0)
end
function s.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePositionRush()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.dspfilter,tp,LOCATION_MZONE,0,nil)
	if #g>0 then
		local c=e:GetHandler()
		for tc in g:Iter() do
			--Prevent DARK Spellcasters from being destroyed by opponent's card effects
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3060)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e1:SetValue(s.efilter)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
	local pg=eg:Filter(s.posfilter,nil)
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_SEVENS_ROAD_MAGICIAN) and #pg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.ChangePosition(pg:GetFirst(),POS_FACEUP_DEFENSE)
	end
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetOwnerPlayer()
end