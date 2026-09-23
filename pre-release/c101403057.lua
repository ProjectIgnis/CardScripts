--翅竜の羽撃
--Reindsurm Butterfly
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Send 2 monsters from your Deck to the GY, including an Insect monster, also you cannot Special Summon until the end of the next turn after this card resolves, except Insect monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If you Ritual Summon an Insect monster(s) while this card is in your GY: You can banish this card; all "Reindsurm" monsters you currently control gain 800 ATK/DEF
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.atkcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_REINDSURM}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(aux.AND(Card.IsMonster,Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
		return #g>=2 and g:IsExists(Card.IsRace,1,nil,RACE_INSECT)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsRace,1,nil,RACE_INSECT) 
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsMonster,Card.IsAbleToGrave),tp,LOCATION_DECK,0,nil)
	if #g>=2 then
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOGRAVE)
		if #sg==2 then
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	--Also you cannot Special Summon until the end of the next turn after this card resolves, except Insect monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c)
		return c:IsRaceExcept(RACE_INSECT)
	end)
	e1:SetReset(RESET_PHASE|PHASE_END,2)
	Duel.RegisterEffect(e1,tp)
end
function s.atkconfilter(c,tp)
	return c:IsRitualSummoned() and c:IsRace(RACE_INSECT) and c:IsSummonPlayer(tp) and c:IsFaceup()
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.atkconfilter,1,nil,tp)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_REINDSURM),tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,500)
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,nil,1,tp,500)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_REINDSURM),tp,LOCATION_MZONE,0,nil)
	for tc in g:Iter() do
		--All "Reindsurm" monsters you currently control gain 800 ATK/DEF
		tc:UpdateAttack(800,nil,c)
		tc:UpdateDefense(800,nil,c)
	end
end