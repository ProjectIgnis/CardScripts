--壺魔人 (Anime)
--Dragon Piper (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Once per turn: You can place 1 Dragon-Type monster under a "Dragon Capture Jar" you control on your side of the field and if you do, it becomes unaffected by "Dragon Capture Jar"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.dragcapjartg)
	e1:SetOperation(s.dragcapjarop)
	c:RegisterEffect(e1)
end
s.listed_names={50045299} --"Dragon Capture Jar"
function s.dragcapjarfilter(c)
	return c:IsFaceup() and c:IsCode(50045299) and c:GetOverlayGroup():IsExists(Card.IsRace,1,nil,RACE_DRAGON)
end
function s.dragcapjartg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMZoneCount(tp)>0 
		and Duel.IsExistingMatchingCard(s.dragcapjarfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
end
function s.dragcapjarop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,s.dragcapjarfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		local og=tc:GetOverlayGroup():Filter(Card.IsRace,nil,RACE_DRAGON)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local sc=og:Select(tp,1,1,nil):GetFirst()
		Duel.MoveToField(sc,tp,tp,LOCATION_MZONE,POS_FACEUP,true)
		--Prevent moving 
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_CONTROL)
		e1:SetValue(e:GetHandlerPlayer())
		e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TOFIELD)
		sc:RegisterEffect(e1)
		--Unaffected by "Dragon Capture Jar"
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		e2:SetValue(function(e,te) return te:GetHandler():IsCode(511001040) end)
		sc:RegisterEffect(e2)
	end
end
