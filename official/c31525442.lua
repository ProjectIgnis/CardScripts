--予見者ゾルガ
--Zolga the Prophet
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--If you control an EARTH Fairy monster, except "Zolga the Prophet": You can Special Summon this card from your hand, then look at up to 5 cards from the top of each player's Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--When a monster that was Normal Summoned by Tributing this card declares an attack: You can banish this card from your GY; destroy that monster, and if you do, inflict 2000 damage to your opponent
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2a:SetCode(EVENT_BE_MATERIAL)
	e2a:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local rc=c:GetReasonCard()
		return r==REASON_SUMMON and c:IsLocation(LOCATION_GRAVE) and rc:IsTributeSummoned() and rc:IsFaceup()
	end)
	e2a:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		local rc=c:GetReasonCard()
		rc:RegisterFlagEffect(id,RESET_EVENT|(RESETS_STANDARD&~(RESET_TEMP_REMOVE|RESET_LEAVE)),EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,2))
		--Reset the flag effect + hint on the Tribute Summoned monster if this card moves from the GY
		local e0=Effect.CreateEffect(c)
		e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetCode(EVENT_MOVE)
		e0:SetOperation(function()
			if rc:HasFlagEffect(id) and rc:GetFlagEffectLabel(id)==fid then
				rc:ResetFlagEffect(id)
			end
			e0:Reset()
		end)
		c:RegisterEffect(e0)
	end)
	c:RegisterEffect(e2a)
	local e2b=Effect.CreateEffect(c)
	e2b:SetDescription(aux.Stringid(id,1))
	e2b:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2b:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2b:SetRange(LOCATION_GRAVE)
	e2b:SetCountLimit(1,{id,1})
	e2b:SetCondition(s.descon)
	e2b:SetCost(Cost.SelfBanish)
	e2b:SetTarget(s.destg)
	e2b:SetOperation(s.desop)
	c:RegisterEffect(e2b)
end
s.listed_names={id}
function s.spconfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_FAIRY) and c:IsFaceup() and not c:IsCode(id)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local your_deck_count=math.min(5,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0))
		local oppo_deck_count=math.min(5,Duel.GetFieldGroupCount(tp,0,LOCATION_DECK))
		local look_count=0
		local break_chk=true
		if your_deck_count>0 then
			break_chk=false
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
			look_count=your_deck_count==1 and your_deck_count or Duel.AnnounceNumberRange(tp,1,your_deck_count)
			Duel.ConfirmCards(tp,Duel.GetDecktopGroup(tp,look_count))
		end
		if oppo_deck_count>0 then
			if break_chk then Duel.BreakEffect() end
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,4))
			look_count=oppo_deck_count==1 and oppo_deck_count or Duel.AnnounceNumberRange(tp,1,oppo_deck_count)
			Duel.ConfirmCards(tp,Duel.GetDecktopGroup(1-tp,look_count))
		end
	end
end
function s.descon(e,tp,eg,ev,ep,re,r,rp)
	local bc=Duel.GetAttacker()
	return bc:HasFlagEffect(id) and bc:GetFlagEffectLabel(id)==e:GetHandler():GetFieldID()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=Duel.GetAttacker()
	if chk==0 then return bc:IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,2000)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttacker()
	if bc:IsRelateToBattle() and Duel.Destroy(bc,REASON_EFFECT)>0 then
		Duel.Damage(1-tp,2000,REASON_EFFECT)
	end
end