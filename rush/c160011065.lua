--リベンジ・マックス
--Revenge MAX
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Gain LP equal to targeted monster's level x 200, then return it to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tc=Duel.SelectMatchingCard(tp,Card.IsSpellTrap,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler()):GetFirst()
	if tc then
		Duel.HintSelection(tc,true)
		if Duel.Destroy(tc,REASON_EFFECT)>0 and tc:IsEquipSpell()
			and eg:IsExists(aux.FaceupFilter(Card.IsLevelBelow,8),1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local sg=eg:FilterSelect(tp,aux.FaceupFilter(Card.IsLevelBelow,8),1,1,nil)
			Duel.HintSelection(sg,true)
			Duel.BreakEffect()
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end