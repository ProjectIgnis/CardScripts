--夢中の再誕
--Delirium Rebirth
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,s.ffilter,Fusion.OnFieldMat(Card.IsFaceup),s.fextra)
	c:RegisterEffect(e1)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_DRAW)
	e3:SetCondition(s.condition2)
	c:RegisterEffect(e3)
end
function s.ffilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.fusfilter(c,tp)
	return c:IsControler(tp)
end
function s.checkmat(tp,sg,fc)
	local mg1=sg:Filter(s.fusfilter,nil,tp)
	return #sg==2 and #mg1>0
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(aux.FaceupFilter(Card.IsLevelBelow,9)),tp,0,LOCATION_ONFIELD,nil),s.checkmat
end
function s.filter1(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE)
end
function s.genericcondition(tp)
	return Duel.IsTurnPlayer(1-tp) and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,1,nil,RACE_INSECT)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,tp) and s.genericcondition(tp)
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and s.genericcondition(tp)
end