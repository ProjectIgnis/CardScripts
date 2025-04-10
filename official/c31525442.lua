--予見者ゾルガ
--Zolga the Prophet
--Scripted by The Razgriz
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon/Look at top 5 cards
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetCondition(s.con)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_EARTH) and not c:IsCode(id)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		Duel.BreakEffect()
		s.look(tp,tp)
		s.look(tp,1-tp)
	end
end
function s.look(tp,p)
	local gc=math.min(5,Duel.GetFieldGroupCount(p,LOCATION_DECK,0))
	if gc>0 then
		local ac=gc==1 and gc or Duel.AnnounceNumberRange(tp,1,gc)
		Duel.ConfirmCards(tp,Duel.GetDecktopGroup(p,ac))
	end
end
function s.con(e,tp,eg,ev,ep,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetReasonCard()
	local at=Duel.GetAttacker()
	return (e:GetHandler():IsReason(REASON_RELEASE) and not e:GetHandler():IsReason(REASON_EFFECT)) and tc and tc:IsMonster() and at==tc
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local at=Duel.GetAttacker()
	local tc=e:GetHandler():GetReasonCard()
	if (e:GetHandler():IsReason(REASON_RELEASE) and not e:GetHandler():IsReason(REASON_EFFECT)) and tc:IsReason(REASON_SUMMON) and tc:IsMonster() and at==tc then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetHandler():GetReasonCard()
	local at=Duel.GetAttacker()
	if not tc:IsReason(REASON_SUMMON) or (not c:IsReason(REASON_RELEASE) or c:IsReason(REASON_EFFECT)) and not at==tc then return end
	if at==tc then 
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			Duel.Damage(1-tp,2000,REASON_EFFECT)
		end
	end
end