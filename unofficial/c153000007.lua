--炎の剣士 (Deck Master)
--Flame Swordsman (Deck Master)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	if not DeckMaster then
		return
	end
	--Deck Master Effect
	local dme1=Effect.CreateEffect(c)
	dme1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	dme1:SetCode(EVENT_FREE_CHAIN)
	dme1:SetCondition(s.con)
	dme1:SetOperation(s.op)
	DeckMaster.RegisterAbilities(c,dme1)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	return Duel.IsTurnPlayer(tp) and Duel.IsMainPhase() and Duel.GetDeckMaster(tp)==c and c:GetAttack()>100
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	local op=1
	if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_WARRIOR),tp,LOCATION_MZONE,LOCATION_MZONE,1,c) then
		op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
	end
	if op==0 then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Hint(HINT_CARD,1-tp,id)
		local atk=c:GetAttack()
		local multiple=math.floor(atk/100)
		if atk%100==0 then multiple=multiple-1 end
		local i=1
		local multiples={}
		while i<=multiple do
			table.insert(multiples,i)
			i=i+1
		end
		local res=Duel.AnnounceNumber(tp,table.unpack(multiples))*100
		c:Attack(atk-res)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local tc=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsRace,RACE_WARRIOR),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c):GetFirst()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(res)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	else
		Duel.Hint(HINT_NUMBER,tp,c:Attack())
	end
end