--究極封印神エクゾディオス (Anime)
--Exodius the Ultimate Forbidden Lord (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--Send 1 "Forbidden One" monster from your Hand or Deck to the Graveyard
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetTarget(s.forbtg)
	e2:SetOperation(s.forbop)
	c:RegisterEffect(e2)
	--ATK
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.atkval)
	c:RegisterEffect(e3)
	--indes
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--Unaffected by Opponent Card Effects
	local e5=e3:Clone()
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetValue(s.unval)
	c:RegisterEffect(e5)
	--Win the Duel when there are 5 parts of the Forbidden in your Graveyard
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetRange(LOCATION_MZONE)
	e6:SetOperation(s.winop)
	c:RegisterEffect(e6)
end
s.listed_series={0x40}
s.listed_names={511000244}
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(511000244) or Duel.GetChainInfo(0,CHAININFO_TRIGGERING_CODE)==511000244
end
function s.forbtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.forbfilter(c)
	return c:IsSetCard(0x40) and c:IsMonster() and c:IsAbleToGrave()
end
function s.forbop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,s.forbfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(Card.IsSetCard,c:GetControler(),LOCATION_GRAVE,0,nil,0x40)*1000
end
function s.unval(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.check(g)
	g=g:Filter(Card.IsSetCard,nil,0x40)
	return g:GetClassCount(Card.GetCode)>=5
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetFieldGroup(tp,LOCATION_GRAVE,0)
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE)
	local wtp=s.check(g1)
	local wntp=s.check(g2)
	if wtp and not wntp then
		Duel.Win(tp,WIN_REASON_EXODIUS)
	elseif not wtp and wntp then
		Duel.Win(1-tp,WIN_REASON_EXODIUS)
	elseif wtp and wntp then
		Duel.Win(PLAYER_NONE,WIN_REASON_EXODIUS)
	end
end
