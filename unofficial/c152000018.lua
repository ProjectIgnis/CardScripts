--マスターストームアクセス
--Master Storm Access
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--skill
	aux.AddVrainsSkillProcedure(c,s.flipcon,s.flipop)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	--opt Register
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,0)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	if aux.CheckSkillNegation(e,tp) then return end
	--Add Cyberse monster to Extra Deck
	s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,RACE_CYBERSE,OPCODE_ISRACE,OPCODE_AND}
	local storm=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	local tc=Duel.CreateToken(tp,storm)
	if tc:IsAbleToDeck() then
		Duel.SendtoDeck(tc,tp,0,REASON_EFFECT)
	end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
end